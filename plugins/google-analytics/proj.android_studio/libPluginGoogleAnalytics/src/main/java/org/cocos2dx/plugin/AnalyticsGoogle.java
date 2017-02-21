package org.cocos2dx.plugin;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.analytics.ExceptionReporter;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.Thread.UncaughtExceptionHandler;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Map;

public class AnalyticsGoogle implements InterfaceAnalytics {
    protected static final String          LOG_TAG          = AnalyticsGoogle.class.getName();
    protected              Context         _context         = null;
    protected static       boolean         _debugEnabled    = false;
    protected              GoogleAnalytics _googleAnalytics = null;
    protected              Tracker         _currentTracker  = null;

    private Map<String, Tracker> _registeredTrackers = null;

    @SuppressWarnings("unused") // JNI method.
    public AnalyticsGoogle(Context context) {
        _registeredTrackers = new HashMap<>();
        _context = context;
        _googleAnalytics = GoogleAnalytics.getInstance(context);
    }

    private void logD(String msg) {
        if (_debugEnabled) {
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

    private Tracker _getTrackerWithId(String trackerId) {
        return _registeredTrackers.get(trackerId);
    }

    private void _registerTracker(Tracker tracker, String trackerId) {
        _registeredTrackers.put(trackerId, tracker);
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

        Tracker tracker = _getTrackerWithId(trackerId);
        if (null == tracker) {
            logD("Trying to enable unknown tracker id: " + trackerId);
        } else {
            logD("Selected tracker id: " + trackerId);
            _enableTracker(tracker);
        }
    }

    @SuppressWarnings("WeakerAccess")
    public void createTracker(String trackerId) {
        logD("createTracker: id = " + trackerId);
        Tracker tracker = _getTrackerWithId(trackerId);
        if (null == tracker) {
            tracker = _googleAnalytics.newTracker(trackerId);
            _registerTracker(tracker, trackerId);
        }

        _enableTracker(tracker);
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
    public void dispatchPeriodically(int seconds) {
        _googleAnalytics.setLocalDispatchPeriod(seconds);
    }

    @SuppressWarnings("unused") // JNI method.
    public void stopPeriodicalDispatch() {
        _googleAnalytics.setLocalDispatchPeriod(-1);
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

    @SuppressWarnings("WeakerAccess")
    public void setDryRun(boolean isDryRun) {
        _googleAnalytics.setDryRun(isDryRun);
    }

    @SuppressWarnings("unused")
    public void enableAdvertisingTracking(boolean enabled) {
        if (null != _currentTracker) {
            _currentTracker.enableAdvertisingIdCollection(enabled);
        } else {
            Log.e(LOG_TAG, "Advertising called w/o valid tracker.");
        }
    }

    @Override
    public void startSession(String appKey) {
        if (_currentTracker != null) {
            _currentTracker.setScreenName(appKey);
            _currentTracker.send(new HitBuilders.ScreenViewBuilder().setNewSession().build());
        } else {
            Log.e(LOG_TAG, "Start session called w/o valid tracker.");
        }
    }

    @Override
    public void stopSession() {
        if (_currentTracker != null) {
            _currentTracker.send((new HitBuilders.ScreenViewBuilder().set("&sc", "end")).build());
        } else {
            Log.e(LOG_TAG, "Start session called w/o valid tracker.");
        }
    }

    @Override
    public void setSessionContinueMillis(int millis) {
        Log.i(LOG_TAG, "Not supported on Android");
    }

    @Override
    public void setCaptureUncaughtException(boolean isEnabled) {
        if (isEnabled) {
            if (null != _currentTracker) {
                UncaughtExceptionHandler myHandler = new ExceptionReporter(_currentTracker,
                    Thread.getDefaultUncaughtExceptionHandler(), _context);
                Thread.setDefaultUncaughtExceptionHandler(myHandler);
            } else {
                Log.e(LOG_TAG, "setCaptureUncaughtException called w/o valid tracker.");
            }
        } else {
            Thread.setDefaultUncaughtExceptionHandler(null);
        }
    }

    @Override
    public void setDebugMode(boolean isDebugMode) {
        _debugEnabled = isDebugMode;
        setDryRun(_debugEnabled);
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
