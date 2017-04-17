/****************************************************************************
 * Copyright (c) 2012-2013 cocos2d-x.org
 * <p>
 * http://www.cocos2d-x.org
 * <p>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p>
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <p>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.plugin;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.os.Build;
import android.os.Bundle;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Display;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.google.ads.mediation.admob.AdMobAdapter;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.NativeExpressAdView;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

public class AdsAdmob implements InterfaceAds, PluginListener {
    @Override
    public void onStart() { }

    @Override
    public void onResume() {
        if (_rewardedVideoAd != null) {
            _rewardedVideoAd.resume(_context);
        }
        for (AdViewInfo adView : _adViewInfos.values()) {
            adView.resume();
        }
    }

    @Override
    public void onPause() {
        if (_rewardedVideoAd != null) {
            _rewardedVideoAd.pause(_context);
        }
        for (AdViewInfo adView : _adViewInfos.values()) {
            adView.pause();
        }
    }

    @Override
    public void onStop() { }

    @Override
    public void onDestroy() {
        if (_rewardedVideoAd != null) {
            _rewardedVideoAd.destroy(_context);
        }
        for (AdViewInfo adView : _adViewInfos.values()) {
            adView.destroy();
        }
        _adViewInfos.clear();
    }

    @Override
    public void onBackPressed() { }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return false;
    }

    private static class AdType {
        private static final int Banner        = 1;
        private static final int NativeExpress = 2;
    }

    private static final String LOG_TAG = AdsAdmob.class.getName();

    private Activity _context = null;

    private boolean bDebug = true;

    private       boolean        _isInterstitialAdLoaded       = false;
    private final Object         _isInterstitialAdLoadedLocker = new Object();
    private       InterstitialAd _interstitialAd               = null;

    private       boolean         _isRewardedVideoAdLoaded       = false;
    private final Object          _isRewardedVideoAdLoadedLocker = new Object();
    private       RewardedVideoAd _rewardedVideoAd               = null;

    private AtomicBoolean _isAdColonyInitializing     = new AtomicBoolean(false);
    private AtomicBoolean _isAdColonyInitialized      = new AtomicBoolean(false);
    private String        _adColonyAppId              = null;
    private String        _adColonyInterstitialZoneId = null;
    private String        _adColonyRewardedZoneId     = null;
    private String        _adColonyClientOptions      = null;

    private       Set<String> _testDeviceIds       = null;
    private final Object      _testDeviceIdsLocker = new Object();

    private HashMap<String, AdViewInfo> _adViewInfos = null;

    void logE(String msg) {
        Log.e(LOG_TAG, msg);
    }

    private void logE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
    }

    private void logI(String msg) {
        Log.i(LOG_TAG, msg);
    }

    void logD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public AdsAdmob(Context context) {
        logI("constructor: begin.");

        _context = (Activity) context;
        PluginWrapper.addListener(this);
        _testDeviceIds = new HashSet<>();

        _adViewInfos = new HashMap<>();

        logI("constructor: end.");
    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "9.0.0";
    }

    private void _runOnMainThread(Runnable r) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            r.run();
        } else {
            PluginWrapper.runOnMainThread(r);
        }
    }

    @SuppressWarnings("unused")
    public void initialize(@NonNull final String applicationId) {
        logD("initialize: applicationId = " + applicationId);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("initialize: main thread begin.");
                MobileAds.initialize(_context.getApplicationContext(), applicationId);
                NativeCallback callback = new NativeCallback() {
                    @Override
                    public void onEvent(@NonNull Integer code, @NonNull String message) {
                        AdsWrapper.onAdsResult(AdsAdmob.class.getName(), code, message);
                    }
                };
                _rewardedVideoAd = MobileAds.getRewardedVideoAdInstance(_context);
                _rewardedVideoAd.setRewardedVideoAdListener(new RewardedAdListener(callback) {
                    @Override
                    public void onRewardedVideoAdLoaded() {
                        super.onRewardedVideoAdLoaded();
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewardedVideoAdFailedToLoad(int errorCode) {
                        super.onRewardedVideoAdFailedToLoad(errorCode);
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewardedVideoAdOpened() {
                        super.onRewardedVideoAdOpened();
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewardedVideoStarted() {
                        super.onRewardedVideoStarted();
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewardedVideoAdClosed() {
                        super.onRewardedVideoAdClosed();
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewarded(RewardItem reward) {
                        super.onRewarded(reward);
                        _refreshRewardedAdAvailability();
                    }

                    @Override
                    public void onRewardedVideoAdLeftApplication() {
                        super.onRewardedVideoAdLeftApplication();
                        _refreshRewardedAdAvailability();
                    }
                });
                logD("initialize: main thread end.");
            }
        });
        logD("initialize: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void addTestDevice(@NonNull String deviceId) {
        synchronized (_testDeviceIdsLocker) {
            _testDeviceIds.add(deviceId);
        }
    }

    private void _addTestDeviceIds(@NonNull AdRequest.Builder builder) {
        synchronized (_testDeviceIdsLocker) {
            for (String deviceId : _testDeviceIds) {
                builder.addTestDevice(deviceId);
            }
        }
    }

    @SuppressWarnings("unused") // JNI method.
    public void configMediationAdColony(final JSONObject params) {
        logD("configMediationAdColony: json = " + params);

        if (!AdColonyMediation.isLinkedWithAdColony()) {
            logE("configMediationAdColony: AdColony is not linked!");
        }

        if (_isAdColonyInitialized.get()) {
            logE("configMediationAdColony: already initialized!");
            return;
        }

        if (_isAdColonyInitializing.getAndSet(true)) {
            logE("configMediationAdColony: is initializing!");
            return;
        }

        String versionName = null;

        try {
            PackageInfo info =
                _context.getPackageManager().getPackageInfo(_context.getPackageName(), 0);
            versionName = info.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        if (versionName != null) {
            _adColonyAppId = null;
            _adColonyInterstitialZoneId = null;
            _adColonyRewardedZoneId = null;
            _adColonyClientOptions = null;

            final String AdColonyAppIdKey = "AdColonyAppID";
            final String AdColonyInterstitialAdIdKey = "AdColonyInterstitialAdID";
            final String AdColonyRewardedAdIdKey = "AdColonyRewardedAdID";

            try {
                _adColonyAppId = params.getString(AdColonyAppIdKey);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (_adColonyAppId != null) {
                final List<String> zoneIds = new ArrayList<>();

                try {
                    _adColonyInterstitialZoneId = params.getString(AdColonyInterstitialAdIdKey);
                    zoneIds.add(_adColonyInterstitialZoneId);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                try {
                    _adColonyRewardedZoneId = params.getString(AdColonyRewardedAdIdKey);
                    zoneIds.add(_adColonyRewardedZoneId);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (!zoneIds.isEmpty()) {
                    _adColonyClientOptions = "version:" + versionName + ",store:google";
                    logI("configMediationAdColony: appId = " + _adColonyAppId +
                         " interstitialZoneId = " + _adColonyInterstitialZoneId +
                         " rewardedZoneId = " + _adColonyRewardedZoneId +
                         " clientOptions: " + _adColonyClientOptions);

                    PluginWrapper.runOnMainThread(new Runnable() {
                        @Override
                        public void run() {
                            logD("configMediationAdColony: main thread begin.");

                            AdColonyMediation.configure(_context, _adColonyClientOptions,
                                _adColonyAppId, zoneIds.toArray(new String[zoneIds.size()]));

                            _isAdColonyInitializing.set(false);
                            _isAdColonyInitialized.set(true);

                            logD("configMediationAdColony: main thread end.");
                        }
                    });
                } else {
                    logE("configMediationAdColony: not zone ids were successfully parsed!");
                }
            } else {
                logE("configMediationAdColony: missing application id!");
            }
        } else {
            logE("configMediationAdColony: could not retrieve package info!");
        }
    }

    @Override
    @Deprecated
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        logD("configDeveloperInfo: deprecated.");
    }

    @Override
    @Deprecated
    public void showAds(final Hashtable<String, String> info, final int pos) {
        logD("showAds: deprecated.");
    }

    @Override
    public void spendPoints(int points) {
        logD("Admob not support spend points!");
    }

    @Override
    @Deprecated
    public void hideAds(Hashtable<String, String> info) {
        logD("hideAds: deprecated.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void createBannerAd(@NonNull JSONObject params) {
        logD("createBannerAd: begin json = " + params);
        assert (params.length() == 3);

        try {
            String adId = params.getString("Param1");
            Integer width = params.getInt("Param2");
            Integer height = params.getInt("Param3");

            _createAd(AdType.Banner, adId, width, height);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("createBannerAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void createNativeExpressAd(@NonNull JSONObject params) {
        logD("createNativeExpressAd: begin json = " + params);
        assert (params.length() == 3);

        try {
            String adId = params.getString("Param1");
            Integer width = params.getInt("Param2");
            Integer height = params.getInt("Param3");

            _createAd(AdType.NativeExpress, adId, width, height);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("createNativeExpressAd: end.");
    }

    private void _createAd(@NonNull Integer adType, @NonNull String adId, @NonNull Integer width,
                           @NonNull Integer height) {
        AdSize size = new AdSize(width, height);
        if (_hasAd(adId, size)) {
            logD(String.format(Locale.getDefault(),
                "_createAd: attempt to create an ad with id = %s width = %d height = %d but it is" +
                " already created.", adId, width, height));
            return;
        }

        _createAd(adType, adId, size);
    }

    private boolean _hasAd(@NonNull String adId, @NonNull AdSize size) {
        AdViewInfo info = _adViewInfos.get(adId);
        return info != null && info.getAdSize().equals(size);
    }

    private void _createAd(@NonNull final Integer adType, @NonNull final String adId,
                           @NonNull final AdSize size) {
        logD("_createAd: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_createAd: main thread begin.");
                destroyAd(adId);

                AdRequest.Builder builder = new AdRequest.Builder();
                _addTestDeviceIds(builder);
                AdRequest request = builder.build();

                AdViewInfo info = null;
                if (adType == AdType.Banner) {
                    info = _createBannerAd(adId, size, request);
                } else if (adType == AdType.NativeExpress) {
                    info = _createNativeExpressAd(adId, size, request);
                }

                assert (info != null);
                _addAdView(info.getView());

                info.hide();
                _adViewInfos.put(adId, info);
                logD("_createAd: main thread end.");
            }
        });
        logD("_createAd: end.");
    }

    private void _addAdView(View adView) {
        FrameLayout layout = (FrameLayout) ((Activity) PluginWrapper.getContext())
            .findViewById(android.R.id.content)
            .getRootView();

        FrameLayout.LayoutParams params =
            new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT);
        params.gravity = Gravity.LEFT | Gravity.TOP;

        layout.addView(adView, params);
    }

    private AdViewInfo _createBannerAd(@NonNull String adId, @NonNull AdSize size,
                                       @NonNull AdRequest request) {
        AdView view = new AdView(_context);
        view.setAdSize(size);
        view.setAdUnitId(adId);
        return new AdViewInfo(new NativeCallback() {
            @Override
            public void onEvent(@NonNull Integer code, @NonNull String message) {
                AdsWrapper.onAdsResult(AdsAdmob.class.getName(), code, message);
            }
        }, view, request);
    }

    private AdViewInfo _createNativeExpressAd(@NonNull String adId, @NonNull AdSize size,
                                              @NonNull AdRequest request) {
        NativeExpressAdView view = new NativeExpressAdView(_context);
        view.setAdSize(size);
        view.setAdUnitId(adId);
        return new AdViewInfo(new NativeCallback() {
            @Override
            public void onEvent(@NonNull Integer code, @NonNull String message) {
                AdsWrapper.onAdsResult(AdsAdmob.class.getName(), code, message);
            }
        }, view, request);
    }

    @SuppressWarnings("unused") // JNI method.
    public void destroyAd(@NonNull final String adId) {
        logD("destroyAd: begin adId = " + adId);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("destroyAd: main thread begin.");
                AdViewInfo info = _adViewInfos.get(adId);
                if (info != null) {
                    info.destroy();
                } else {
                    logD("destroyAd: attempted to destroy a non-created ad with id = " + adId);
                }
                logD("destroyAd: main thread end.");
            }
        });
        logD("destroyAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void showAd(@NonNull final String adId) {
        logD("showAd: begin adId = " + adId);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("showAd: main thread begin.");
                AdViewInfo info = _adViewInfos.get(adId);
                if (info != null) {
                    info.show();
                } else {
                    logD("showAd: attempted to show a non-created ad with id = " + adId);
                }
                logD("showAd: main thread end.");
            }
        });
        logD("showAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void hideAd(@NonNull final String adId) {
        logD("hideAd: begin adId = " + adId);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("hideAd: main thread begin.");
                AdViewInfo info = _adViewInfos.get(adId);
                if (info != null) {
                    info.hide();
                } else {
                    logD("hideAd: attempted to show a non-created ad with id = " + adId);
                }
                logD("hideAd: main thread end.");
            }
        });
        logD("hideAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void moveAd(@NonNull JSONObject params) {
        logD("moveAd: begin json = " + params);
        assert (params.length() == 3);

        try {
            String adId = params.getString("Param1");
            Integer x = params.getInt("Param2");
            Integer y = params.getInt("Param3");

            _moveAd(adId, x, y);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("moveAd: end.");
    }

    private void _moveAd(@NonNull final String adId, @NonNull final Integer x,
                         @NonNull final Integer y) {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                AdViewInfo info = _adViewInfos.get(adId);
                if (info != null) {
                    info.move(x, y);
                } else {
                    logD("_moveAd: attempted to move a non-created ad with id = " + adId);
                }
            }
        });
    }

    /**
     * synchronized?
     */
    @SuppressWarnings("unused") // JNI method.
    public void showInterstitialAd() {
        logD("showInterstitial: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("showInterstitial: main thread begin.");
                if (_interstitialAd.isLoaded()) {
                    _interstitialAd.show();
                } else {
                    // Ad is not ready to present.
                    logD("showInterstitial: interstitial is not ready.");
                }
                logD("showInterstitial: main thread end.");
            }
        });
        logD("showInterstitial: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public void loadInterstitialAd(@NonNull final String adId) {
        logD("loadInterstitialAd: begin adId = " + adId);

        // Only loadAd and creating AdRequest must perform on UI Thread.
        // https://groups.google.com/forum/#!topic/google-admob-ads-sdk/a342zlMTax0

        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("loadInterstitialAd: main thread begin.");
                _removeInterstitialAd();

                NativeCallback callback = new NativeCallback() {
                    @Override
                    public void onEvent(@NonNull Integer code, @NonNull String message) {
                        AdsWrapper.onAdsResult(AdsAdmob.class.getName(), code, message);
                    }
                };

                _interstitialAd = new InterstitialAd(_context);
                _interstitialAd.setAdUnitId(adId);
                _interstitialAd.setAdListener(new InterstitialAdListener(callback) {
                    @Override
                    public void onAdLoaded() {
                        super.onAdLoaded();
                        _refreshInterstitialAdAvailability();
                    }

                    @Override
                    public void onAdFailedToLoad(int errorCode) {
                        super.onAdFailedToLoad(errorCode);
                        _refreshInterstitialAdAvailability();
                    }

                    @Override
                    public void onAdOpened() {
                        super.onAdOpened();
                        _refreshInterstitialAdAvailability();
                    }

                    @Override
                    public void onAdClosed() {
                        super.onAdClosed();
                        _refreshInterstitialAdAvailability();
                    }

                    @Override
                    public void onAdLeftApplication() {
                        super.onAdLeftApplication();
                        _refreshInterstitialAdAvailability();
                    }
                });
                _interstitialAd.setInAppPurchaseListener(new IAPListener(AdsAdmob.this));

                AdRequest.Builder builder = new AdRequest.Builder();
                _addTestDeviceIds(builder);

                if (_isAdColonyInitialized.get() && _adColonyInterstitialZoneId != null &&
                    AdColonyMediation.isLinkedWithAdColony()) {
                    AdColonyMediation.addNetworkExtrasBundle(builder, _adColonyInterstitialZoneId);
                }

                _interstitialAd.loadAd(builder.build());
                logD("loadInterstitialAd: main thread end.");
            }
        });

        logD("loadInterstitialAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public boolean hasInterstitialAd() {
        synchronized (_isInterstitialAdLoadedLocker) {
            return _isInterstitialAdLoaded;
        }
    }

    private void _removeInterstitialAd() {
        if (_interstitialAd != null) {
            _interstitialAd = null;
        }
    }

    private void _refreshInterstitialAdAvailability() {
        synchronized (_isInterstitialAdLoadedLocker) {
            _isInterstitialAdLoaded = _interstitialAd.isLoaded();
        }
    }

    @Override
    public String getPluginVersion() {
        return "0.2.0";
    }

    @Override
    public void queryPoints() {
        logD("Admob not support query points!");
    }

    /**
     * synchronized?
     */
    @SuppressWarnings("unused") // JNI method.
    public void showRewardedAd() {
        logD("showRewardedAd: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("showRewardedAd: main thread begin.");
                _rewardedVideoAd.show();
                logD("showRewardedAd: main thread end.");
            }
        });
        logD("showRewardedAd: end.");
    }

    /**
     * synchronized?
     */
    @SuppressWarnings("unused") // JNI method.
    public void loadRewardedAd(final @NonNull String rewardedAdId) {
        logD("loadRewardedAd: begin id = " + rewardedAdId);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("loadRewardedAd: main thread begin.");
                AdRequest.Builder builder = new AdRequest.Builder();

                Bundle extras = new Bundle();
                builder.addNetworkExtrasBundle(AdMobAdapter.class, extras);

                if (_isAdColonyInitialized.get() && _adColonyRewardedZoneId != null &&
                    AdColonyMediation.isLinkedWithAdColony()) {
                    AdColonyMediation.addNetworkExtrasBundle(builder, _adColonyRewardedZoneId);
                }

                AdRequest request = builder.build();
                _rewardedVideoAd.loadAd(rewardedAdId, request);
                logD("loadRewardedAd: main thread end.");
            }
        });
        logD("loadRewardedAd: end.");
    }

    @SuppressWarnings("unused") // JNI method.
    public boolean hasRewardedAd() {
        synchronized (_isRewardedVideoAdLoadedLocker) {
            return _isRewardedVideoAdLoaded;
        }
    }

    void _refreshRewardedAdAvailability() {
        synchronized (_isRewardedVideoAdLoadedLocker) {
            _isRewardedVideoAdLoaded = _rewardedVideoAd.isLoaded();
        }
    }

    @SuppressWarnings("unused") // JNI method.
    public int getSizeInPixels(int size) {
        return _getSizeInPixels(size);
    }

    private int _getSizeInPixels(@NonNull Integer size) {
        if (size == AdSize.AUTO_HEIGHT) {
            return _getAutoHeightInPixels();
        }
        if (size == AdSize.FULL_WIDTH) {
            return _getFullWidthInPixels();
        }
        AdSize adSize = new AdSize(size, size);
        return adSize.getHeightInPixels(_context);
    }

    private int _getAutoHeightInPixels() {
        return AdSize.SMART_BANNER.getHeightInPixels(_context);
    }

    private int _getFullWidthInPixels() {
        return AdSize.SMART_BANNER.getWidthInPixels(_context);
    }

    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private Point _getRealScreenSizeInPixelsForApi17(Display display) {
        DisplayMetrics metrics = new DisplayMetrics();
        display.getRealMetrics(metrics);
        int width = metrics.widthPixels;
        int height = metrics.heightPixels;
        return new Point(width, height);
    }

    @TargetApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    private Point _getRealScreenSizeInPixelsForApi14(Display display) {
        int width;
        int height;
        try {
            Method getRawW = Display.class.getMethod("getRawWidth");
            Method getRawH = Display.class.getMethod("getRawHeight");
            width = (Integer) getRawW.invoke(display);
            height = (Integer) getRawH.invoke(display);
        } catch (Exception e) {
            e.printStackTrace();
            Point size = _getRealScreenSizeInPixelsForApi1(display);
            width = size.x;
            height = size.y;
        }
        return new Point(width, height);
    }

    private Point _getRealScreenSizeInPixelsForApi1(Display display) {
        DisplayMetrics metrics = new DisplayMetrics();
        display.getMetrics(metrics);
        int width = metrics.widthPixels;
        int height = metrics.heightPixels;
        return new Point(width, height);
    }

    private Point _getRealScreenSizeInPixels() {
        // http://stackoverflow.com/questions/14341041/how-to-get-real-screen-height-and-width
        // http://stackoverflow.com/questions/16503064/how-to-get-screen-size-in-android
        // -including-virtual-buttons
        WindowManager wm = (WindowManager) _context.getSystemService(Context.WINDOW_SERVICE);
        Display display = wm.getDefaultDisplay();
        Point size;
        if (Build.VERSION.SDK_INT >= 17) {
            size = _getRealScreenSizeInPixelsForApi17(display);
        } else if (Build.VERSION.SDK_INT >= 14) {
            size = _getRealScreenSizeInPixelsForApi14(display);
        } else {
            size = _getRealScreenSizeInPixelsForApi1(display);
        }
        return size;
    }

    @SuppressWarnings("unused") // JNI method.
    public int getRealScreenWidthInPixels() {
        Point size = _getRealScreenSizeInPixels();
        return size.x;
    }

    @SuppressWarnings("unused") // JNI method.
    public int getRealScreenHeightInPixels() {
        Point size = _getRealScreenSizeInPixels();
        return size.y;
    }
}
