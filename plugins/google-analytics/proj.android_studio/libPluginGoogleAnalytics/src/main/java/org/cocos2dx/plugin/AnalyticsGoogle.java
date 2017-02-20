package org.cocos2dx.plugin;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.analytics.ExceptionReporter;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;
import com.google.android.gms.analytics.ecommerce.Product;
import com.google.android.gms.analytics.ecommerce.ProductAction;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.Thread.UncaughtExceptionHandler;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;

public class AnalyticsGoogle implements InterfaceAnalytics {
    protected static final String          LOG_TAG              = AnalyticsGoogle.class.getName();
    protected              Context         _context             = null;
    protected static       boolean         isDebug              = false;
    protected              GoogleAnalytics _googleAnalytics     = null;
    protected              Tracker         _currentTracker      = null;
    protected              boolean         mCrashUncaughtEnable = false;

    private Map<String, Tracker> _registeredTrackers = null;

    @SuppressWarnings("unused") // JNI method.
    public AnalyticsGoogle(Context context) {
        _registeredTrackers = new HashMap<>();
        _context = context;
        _googleAnalytics = GoogleAnalytics.getInstance(context);
    }

    private void logD(String msg) {
        if (isDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    @SuppressWarnings("unused") // JNI method.
    public void configureTracker(String trackerId) {
        logD("configureTracker: id = " + trackerId);
        if (null == trackerId) {
            logD("configureTracker: null tracker id at configure time.");
            return;
        }

        createTracker(trackerId);
    }

    public void createTracker(String trackerId) {
        logD("createTracker: id = " + trackerId);
        Tracker tracker = _registeredTrackers.get(trackerId);
        if (null == tracker) {
            tracker = _googleAnalytics.newTracker(trackerId);
            _registeredTrackers.put(trackerId, tracker);
        }

        _enableTracker(tracker);
    }

    private void _enableTracker(Tracker tracker) {
        _currentTracker = tracker;
    }

    @SuppressWarnings("unused") // JNI method.
    public void enableTracker(String trackerId) {
        logD("enableTracker: id = " + trackerId);
        if (null == trackerId) {
            return;
        }

        Tracker tracker = _registeredTrackers.get(trackerId);
        if (null == tracker) {
            logD("Trying to enable unknown _currentTracker: " + trackerId);
        } else {
            logD("Selected _currentTracker: " + trackerId);
            _enableTracker(tracker);
        }
    }

    @SuppressWarnings("unused") // JNI method.
    public void setLogLevel(int logLevel) {
        _googleAnalytics.getLogger().setLogLevel(logLevel);
    }

    @SuppressWarnings("unused") // JNI method.
    public void dispatchHits() {
        _googleAnalytics.dispatchLocalHits();
    }

    @SuppressWarnings("unused") // JNI method.
    public void dispatchPeriodically(int numberOfSeconds) {
        _googleAnalytics.setLocalDispatchPeriod(numberOfSeconds);
    }

    @SuppressWarnings("unused") // JNI method.
    public void stopPeriodicalDispatch() {
        _googleAnalytics.setLocalDispatchPeriod(-1);
    }

    @Override
    public void startSession(String appKey) {
        if (this._currentTracker != null) {
            this._currentTracker.setScreenName(appKey);
            this._currentTracker.send(new HitBuilders.ScreenViewBuilder().setNewSession().build());
        } else {
            Log.e(LOG_TAG, "Start session called w/o valid _currentTracker.");
        }
    }

    @Override
    public void stopSession() {
        if (this._currentTracker != null) {
            this._currentTracker.send(
                (new HitBuilders.ScreenViewBuilder().set("&sc", "end")).build());
        } else {
            Log.e(LOG_TAG, "Start session called w/o valid _currentTracker.");
        }
    }

    private void _setParameter(String key, String value) {
        if (_currentTracker != null) {
            _currentTracker.set(key, value);
        }
    }

    @SuppressWarnings("unused") // JNI method.
    public void setParameter(JSONObject dict) {
        try {
            String param1 = dict.getString("Param1");
            String param2 = dict.getString("Param2");
            _setParameter(param1, param2);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private Map<String, String> _convertToMap(JSONObject dict) throws JSONException {
        Map<String, String> map = new HashMap<>();
        Iterator<String> keys = dict.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            String value = dict.getString(key);
            map.put(key, value);
        }
        return map;
    }

    @SuppressWarnings("unused") // JNI method.
    public void sendHit(JSONObject dict) {
        logD("sendHit: dict = " + dict);
        if (_currentTracker != null) {
            try {
                Map<String, String> map = _convertToMap(dict);
                _currentTracker.send(map);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public void trackEcommerceTransactions(JSONObject params) {
        try {
            String identity = params.getString("Param1");
            String name = params.getString("Param2");
            String category = params.getString("Param3");
            double price = params.getDouble("Param4");

            trackEcommerceTransactions(identity, name, category, price);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void trackEcommerceTransactions(String id, String name, String category, double price) {
        logD(String.format(Locale.getDefault(),
            "trackEcommerceTransactions: id = %s name = %s category = %s price = %f", id, name,
            category, price));
        String productID = String.format("Product-%s", id);
        String transactionID = String.format("Transaction-%s", id);

        Product product =
            new Product().setId(productID).setName(name).setCategory(category).setPrice(price);
        ProductAction productAction = new ProductAction(ProductAction.ACTION_PURCHASE)
            .setTransactionId(transactionID)
            .setTransactionRevenue(price);

        HitBuilders.ScreenViewBuilder builder =
            new HitBuilders.ScreenViewBuilder().addProduct(product).setProductAction(productAction);

        if (this._currentTracker != null) {
            this._currentTracker.setScreenName("transaction");
            this._currentTracker.send(builder.build());
        } else {
            Log.e(LOG_TAG, "Log Ecommerce Transactions called w/o valid _currentTracker.");
        }
    }


    void setDryRun(boolean isDryRun) {
        _googleAnalytics.setDryRun(isDryRun);
    }

    void enableAdvertisingTracking(boolean enabled) {
        if (null != this._currentTracker) {
            this._currentTracker.enableAdvertisingIdCollection(enabled);
        } else {
            Log.e(LOG_TAG, "Advertising called w/o valid _currentTracker.");
        }
    }

    @Override
    public void setSessionContinueMillis(int millis) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void setCaptureUncaughtException(boolean isEnabled) {
        mCrashUncaughtEnable = isEnabled;

        if (isEnabled) {
            if (null != _currentTracker) {
                UncaughtExceptionHandler myHandler = new ExceptionReporter(_currentTracker,
                    Thread.getDefaultUncaughtExceptionHandler(), _context);
                Thread.setDefaultUncaughtExceptionHandler(myHandler);
            } else {
                Log.e(LOG_TAG, "setCaptureUncaughtException called w/o valid _currentTracker.");
            }
        } else {
            Thread.setDefaultUncaughtExceptionHandler(null);
        }
    }

    @Override
    public void setDebugMode(boolean isDebugMode) {
        isDebug = isDebugMode;
        setDryRun(isDebug);
    }

    @Override
    public void logError(String errorId, String message) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void logEvent(String eventId) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void logEvent(String eventId, Hashtable<String, String> paramMap) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void logTimedEventBegin(String eventId) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void logTimedEventEnd(String eventId) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public String getSDKVersion() {
        return "7.5.71";
    }

    @Override
    public String getPluginVersion() {
        return "0.9.0";
    }

}
