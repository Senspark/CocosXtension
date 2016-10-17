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
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.jirbo.adcolony.AdColony;
import com.jirbo.adcolony.AdColonyAdapter;
import com.jirbo.adcolony.AdColonyBundleBuilder;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

import static org.cocos2dx.plugin.AdsWrapper.POS_BOTTOM;
import static org.cocos2dx.plugin.AdsWrapper.POS_BOTTOM_LEFT;
import static org.cocos2dx.plugin.AdsWrapper.POS_BOTTOM_RIGHT;
import static org.cocos2dx.plugin.AdsWrapper.POS_CENTER;
import static org.cocos2dx.plugin.AdsWrapper.POS_TOP;
import static org.cocos2dx.plugin.AdsWrapper.POS_TOP_LEFT;
import static org.cocos2dx.plugin.AdsWrapper.POS_TOP_RIGHT;

public class AdsAdmob implements InterfaceAds, PluginListener {
    @Override
    public void onStart() { }

    @Override
    public void onResume() {
        if (AdColony.isConfigured()) {
            AdColony.resume(_context);
        }
    }

    @Override
    public void onPause() {
        if (AdColony.isConfigured()) {
            AdColony.pause();
        }
    }

    @Override
    public void onStop() { }

    @Override
    public void onDestroy() { }

    @Override
    public void onBackPressed() { }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return false;
    }

    @Deprecated
    private static class AdType {
        @Deprecated
        private static final int Banner = 1;

        @Deprecated
        private static final int Interstitial = 2;
    }

    @Deprecated
    private static class Constants {
        @Deprecated
        private static final String AdIdKey = "AdmobID";

        @Deprecated
        private static final String AdIntestitialIdKey = "AdmobInterstitialID";

        @Deprecated
        private static final String AdTypeKey = "AdmobType";

        @Deprecated
        private static final String AdSizeKey = "AdmobSizeEnum";
    }

    private static final List<AdSize> AdSizes =
        Arrays.asList(AdSize.BANNER, AdSize.LARGE_BANNER, AdSize.MEDIUM_RECTANGLE,
            AdSize.FULL_BANNER, AdSize.LEADERBOARD, AdSize.WIDE_SKYSCRAPER, AdSize.SMART_BANNER);

    private static final String LOG_TAG = AdsAdmob.class.getName();

    private Activity _context = null;

    private boolean bDebug = true;

    private AdSize _bannerAdSize = null;
    AdView _bannerAdView = null;

    private AdSize              _nativeExpressAdSize = null;
    private NativeExpressAdView _nativeExpressAdView = null;

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

    @Deprecated
    private String _interstitialAdId = null;

    @Deprecated
    private String _bannerAdId = null;

    private       Set<String> _testDeviceIds       = null;
    private final Object      _testDeviceIdsLocker = new Object();

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

        _lazyInitRewardedAd();

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

    public void configMediationAdColony(final JSONObject params) {
        logD("configMediationAdColony: json = " + params);

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

                            AdColony.configure(_context, _adColonyClientOptions, _adColonyAppId,
                                zoneIds.toArray(new String[zoneIds.size()]));

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
        logD("configDeveloperInfo: info = " + devInfo);
        if (devInfo.contains(Constants.AdIdKey)) {
            _bannerAdId = devInfo.get(Constants.AdIdKey);
        }
        if (devInfo.contains(Constants.AdIntestitialIdKey)) {
            _interstitialAdId = devInfo.get(Constants.AdIntestitialIdKey);
        }
    }

    @Override
    @Deprecated
    public void showAds(final Hashtable<String, String> info, final int pos) {
        final String strType = info.get(Constants.AdTypeKey);
        final int adsType = Integer.parseInt(strType);

        switch (adsType) {
        case AdType.Banner: {
            String strSize = info.get(Constants.AdSizeKey);
            int sizeEnum = Integer.parseInt(strSize);
            if (_bannerAdId != null) {
                _showBannerAd(_bannerAdId, sizeEnum);
                _moveBannerAd(sizeEnum);
            }
            break;
        }
        case AdType.Interstitial: {
            showInterstitialAd();
            break;
        }
        default:
            break;
        }
    }

    @Override
    public void spendPoints(int points) {
        logD("Admob not support spend points!");
    }

    @Override
    @Deprecated
    public synchronized void hideAds(Hashtable<String, String> info) {
        try {
            String strType = info.get(Constants.AdTypeKey);
            int adsType = Integer.parseInt(strType);

            switch (adsType) {
            case AdType.Banner: {
                hideBannerAd();
                break;
            }
            case AdType.Interstitial: {
                logD("Now not support full screen view in Admob");
                break;
            }
            default:
                break;
            }
        } catch (Exception e) {
            logE("Error when hide Ads ( " + info.toString() + " )", e);
        }
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

    public void showBannerAd(@NonNull JSONObject params) {
        logD("showBannerAd: begin json = " + params);
        assert (params.length() == 3);

        try {
            String adId = params.getString("Param1");
            Integer size = params.getInt("Param2");
            Integer position = params.getInt("Param3");

            _showBannerAd(adId, size);
            _moveBannerAd(position);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("showBannerAd: end.");
    }

    private void _showBannerAd(@NonNull final String adId, @NonNull Integer size) {
        logD("_showBannerAd: begin.");
        _bannerAdSize = AdSizes.get(size);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_showBannerAd: main thread begin.");
                hideBannerAd();

                AdView view = new AdView(_context);
                view.setAdSize(_bannerAdSize);
                view.setAdUnitId(adId);
                view.setAdListener(new BannerAdListener(AdsAdmob.this));

                AdRequest.Builder builder = new AdRequest.Builder();
                _addTestDeviceIds(builder);

                view.loadAd(builder.build());
                _addAdView(view);

                _bannerAdView = view;
                logD("_showBannerAd: main thread end.");
            }
        });
        logD("_showBannerAd: end.");
    }

    public void hideBannerAd() {
        logD("hideBannerAd: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("hideBannerAd: main thread begin.");
                if (_hasBannerAd()) {
                    _bannerAdView.setVisibility(View.GONE);
                    _bannerAdView.destroy();
                    _bannerAdView = null;
                }
                logD("hideBannerAd: main thread end.");
            }
        });
        logD("hideBannerAd: end.");
    }

    public void moveBannerAd(@NonNull JSONObject params) {
        logD("moveBannerAd: begin json = " + params);
        assert (params.length() == 2);

        try {
            Integer x = params.getInt("Param1");
            Integer y = params.getInt("Param2");

            _moveBannerAd(x, y);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("moveBannerAd: end.");
    }

    private void _moveBannerAd(@NonNull final Integer x, @NonNull final Integer y) {
        logD("_moveBannerAd: begin x = " + x + " y = " + y);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_moveBannerAd: main thread begin.");
                if (_hasBannerAd()) {
                    _moveAd(_bannerAdView, x, y);
                }
                logD("_moveBannerAd: main thread end.");
            }
        });
        logD("_moveBannerAd: end.");
    }

    private void _moveBannerAd(@NonNull final Integer position) {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (_hasBannerAd()) {
                    _moveAd(_bannerAdView, _bannerAdSize, position);
                }
            }
        });
    }

    boolean _hasBannerAd() {
        return _bannerAdView != null;
    }

    public void showNativeExpressAd(@NonNull final JSONObject params) {
        logD("showNativeExpressAd: begin json = " + params);
        assert (params.length() == 4 || params.length() == 5);

        try {
            String adUnitId = params.getString("Param1");
            Integer width = params.getInt("Param2");
            Integer height = params.getInt("Param3");

            _showNativeExpressAd(adUnitId, width, height);
            _runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (params.length() == 4) {
                            Integer position = params.getInt("Param4");
                            _moveAd(_nativeExpressAdView, _nativeExpressAdSize, position);
                        } else {
                            Integer x = params.getInt("Param4");
                            Integer y = params.getInt("Param5");
                            _moveAd(_nativeExpressAdView, x, y);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("showNativeExpressAd: end.");
    }

    private void _showNativeExpressAd(@NonNull final String adUnitId, @NonNull final Integer width,
                                      @NonNull final Integer height) {
        logD(String.format(Locale.getDefault(),
            "_showNativeExpressAd: begin adUnitId = %s width = %d height = %d.", adUnitId, width,
            height));
        _nativeExpressAdSize = new AdSize(width, height);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_showNativeExpressAd: main thread begin.");
                hideNativeExpressAd();

                NativeExpressAdView view = new NativeExpressAdView(_context);
                view.setAdSize(_nativeExpressAdSize);
                view.setAdUnitId(adUnitId);
                view.setAdListener(new NativeExpressAdListener(AdsAdmob.this, view));

                AdRequest.Builder builder = new AdRequest.Builder();
                _addTestDeviceIds(builder);

                AdRequest request = builder.build();
                view.loadAd(request);

                _addAdView(view);

                _nativeExpressAdView = view;
                logD("_showNativeExpressAd: main thread end.");
            }
        });
        logD("_showNativeExpressAd: end.");
    }

    public void hideNativeExpressAd() {
        logD("hideNativeExpressAd: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("hideNativeExpressAd: main thread begin.");
                if (_hasNativeExpressAd()) {
                    _nativeExpressAdView.setVisibility(View.GONE);
                    _nativeExpressAdView.destroy();
                    _nativeExpressAdView = null;
                }
                logD("hideNativeExpressAd: main thread end.");
            }
        });
        logD("hideNativeExpressAd: end.");
    }

    public void moveNativeExpressAd(@NonNull JSONObject params) {
        logD("moveNativeExpressAd: begin json = " + params);
        assert (params.length() == 2);

        try {
            Integer x = params.getInt("Param1");
            Integer y = params.getInt("Param2");

            _moveNativeExpressAd(x, y);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        logD("moveNativeExpressAd: end.");
    }

    private void _moveNativeExpressAd(@NonNull final Integer x, @NonNull final Integer y) {
        logD("_moveNativeExpressAd: begin x = " + x + " y = " + y);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_moveNativeExpressAd: main thread begin.");
                if (_hasNativeExpressAd()) {
                    _moveAd(_nativeExpressAdView, x, y);
                }
                logD("_moveNativeExpressAd: main thread end.");
            }
        });
        logD("_moveNativeExpressAd: end.");
    }

    private boolean _hasNativeExpressAd() {
        return _nativeExpressAdView != null;
    }

    private void _moveAd(@NonNull final View view, @NonNull final AdSize adSize,
                         @NonNull final Integer position) {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                WindowManager wm =
                    (WindowManager) _context.getSystemService(Context.WINDOW_SERVICE);
                Display display = wm.getDefaultDisplay();

                int screenWidth;
                int screenHeight;

                if (Build.VERSION.SDK_INT >= 13) {
                    Point point = new Point();
                    display.getSize(point);
                    screenWidth = point.x;
                    screenHeight = point.y;
                } else {
                    screenWidth = display.getWidth();
                    screenHeight = display.getHeight();
                }

                int viewWidth = adSize.getWidthInPixels(_context);
                int viewHeight = adSize.getHeightInPixels(_context);

                Point viewOrigin = new Point();
                switch (position) {
                case POS_TOP:
                    viewOrigin.x = (screenWidth - viewWidth) / 2;
                    viewOrigin.y = 0;
                    break;
                case POS_TOP_LEFT:
                    viewOrigin.x = 0;
                    viewOrigin.y = 0;
                    break;
                case POS_TOP_RIGHT:
                    viewOrigin.x = screenWidth - viewWidth;
                    viewOrigin.y = 0;
                    break;
                case POS_BOTTOM:
                    viewOrigin.x = (screenWidth - viewWidth) / 2;
                    viewOrigin.y = screenHeight - viewHeight;
                    break;
                case POS_BOTTOM_LEFT:
                    viewOrigin.x = 0;
                    viewOrigin.y = screenHeight - viewHeight;
                    break;
                case POS_BOTTOM_RIGHT:
                    viewOrigin.x = screenWidth - viewWidth;
                    viewOrigin.y = screenHeight - viewHeight;
                    break;
                case POS_CENTER:
                default:
                    viewOrigin.x = (screenWidth - viewWidth) / 2;
                    viewOrigin.y = (screenHeight - viewHeight) / 2;
                    break;
                }

                _moveAd(view, viewOrigin.x, viewOrigin.y);
            }
        });
    }

    private void _moveAd(@NonNull final View view, @NonNull final Integer x,
                         @NonNull final Integer y) {
        logD("_moveAd: begin view = " + view + " x = " + x + " y = " + y);
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("_moveAd: main thread begin.");
                FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) view.getLayoutParams();
                params.leftMargin = x;
                params.topMargin = y;
                view.setLayoutParams(params);
                logD("_moveAd: main thread end.");
            }
        });
        logD("_moveAd: end.");
    }

    /**
     * synchronized?
     */
    public void showInterstitialAd() {
        logD("showInterstitial: begin.");
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("showInterstitial: main thread begin.");
                if (hasInterstitialAd()) {
                    _interstitialAd.show();
                } else {
                    // Ad is not ready to present.
                    logD("showInterstitial: interstitial is not ready.");
                    // Attempt to load the default interstitial ad id.
                    // Should be deprecated: load interstitial should be call manually.
                    loadInterstitial();
                }
                logD("showInterstitial: main thread end.");
            }
        });
        logD("showInterstitial: end.");
    }

    public synchronized void loadInterstitial() {
        logD("loadInterstitial: begin.");
        if (_interstitialAdId != null) {
            loadInterstitialAd(_interstitialAdId);
        }
        logD("loadInterstitial: end.");
    }

    public void loadInterstitialAd(@NonNull final String adId) {
        logD("loadInterstitialAd: begin adId = " + adId);

        // Only loadAd and creating AdRequest must perform on UI Thread.
        // https://groups.google.com/forum/#!topic/google-admob-ads-sdk/a342zlMTax0

        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("loadInterstitialAd: main thread begin.");
                _removeInterstitialAd();

                _interstitialAd = new InterstitialAd(_context);
                _interstitialAd.setAdUnitId(adId);
                _interstitialAd.setAdListener(
                    new InterstitialAdListener(AdsAdmob.this, _interstitialAd));
                _interstitialAd.setInAppPurchaseListener(new IAPListener(AdsAdmob.this));

                AdRequest.Builder builder = new AdRequest.Builder();
                _addTestDeviceIds(builder);

                if (_isAdColonyInitialized.get() && _adColonyInterstitialZoneId != null) {
                    AdColonyBundleBuilder.setZoneId(_adColonyInterstitialZoneId);
                    builder.addNetworkExtrasBundle(AdColonyAdapter.class,
                        AdColonyBundleBuilder.build());
                }

                _interstitialAd.loadAd(builder.build());
                logD("loadInterstitialAd: main thread end.");
            }
        });
        logD("loadInterstitialAd: end.");
    }

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

    void _changeInterstitialAdAvailability(boolean available) {
        synchronized (_isInterstitialAdLoadedLocker) {
            _isInterstitialAdLoaded = available;
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
    public void showRewardedAd() {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                _lazyInitRewardedAd();
                _rewardedVideoAd.show();
            }
        });
    }

    /**
     * synchronized?
     */
    public void loadRewardedAd(final @NonNull String rewardedAdId) {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                _lazyInitRewardedAd();
                AdRequest.Builder builder = new AdRequest.Builder();

                Bundle extras = new Bundle();
                builder.addNetworkExtrasBundle(AdMobAdapter.class, extras);

                if (_isAdColonyInitialized.get() && _adColonyRewardedZoneId != null) {
                    AdColonyBundleBuilder.setZoneId(_adColonyRewardedZoneId);
                    builder.addNetworkExtrasBundle(AdColonyAdapter.class,
                        AdColonyBundleBuilder.build());
                }

                AdRequest request = builder.build();
                _rewardedVideoAd.loadAd(rewardedAdId, request);
            }
        });
    }

    private void _lazyInitRewardedAd() {
        _runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (_rewardedVideoAd == null) {
                    _rewardedVideoAd = MobileAds.getRewardedVideoAdInstance(_context);
                    _rewardedVideoAd.setRewardedVideoAdListener(
                        new RewardedAdListener(AdsAdmob.this, _rewardedVideoAd));
                }
            }
        });
    }

    public boolean hasRewardedAd() {
        synchronized (_isRewardedVideoAdLoadedLocker) {
            return _isRewardedVideoAdLoaded;
        }
    }

    void _changeRewardedAdAvailability(boolean available) {
        synchronized (_isRewardedVideoAdLoadedLocker) {
            _isRewardedVideoAdLoaded = available;
        }
    }

    public int getBannerWidthInPixel() {
        if (!_hasBannerAd()) {
            return 0;
        }
        return _bannerAdSize.getWidthInPixels(_context);
    }


    public int getBannerHeightInPixel() {
        if (!_hasBannerAd()) {
            return 0;
        }
        return _bannerAdSize.getHeightInPixels(_context);
    }

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
}
