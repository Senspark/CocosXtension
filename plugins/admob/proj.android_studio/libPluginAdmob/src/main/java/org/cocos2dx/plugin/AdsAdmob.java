/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;

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

public class AdsAdmob implements InterfaceAds, PluginListener {

    @Override
    public void onStart() {
    }

    @Override
    public void onResume() {
        if (AdColony.isConfigured()) {
            AdColony.resume(mContext);
        }
    }

    @Override
    public void onPause() {
        if (AdColony.isConfigured()) {
            AdColony.pause();
        }
    }

    @Override
    public void onStop() {
    }

    @Override
    public void onDestroy() {

    }

    @Override
    public void onBackPressed() {

    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return false;
    }

    private static class AdType {
        private static final int Banner = 1;
        private static final int Interstitial = 2;
    }

    private static class Constants {
        private static final String AdIdKey             = "AdmobID";
        private static final String AdIntestitialIdKey  = "AdmobInterstitialID";
        private static final String AdTypeKey           = "AdmobType";
        private static final String AdSizeKey           = "AdmobSizeEnum";
    }

    private static final List<AdSize> AdSizes = Arrays.asList(
            AdSize.BANNER,
            AdSize.LARGE_BANNER,
            AdSize.MEDIUM_RECTANGLE,
            AdSize.FULL_BANNER,
            AdSize.LEADERBOARD,
            AdSize.WIDE_SKYSCRAPER,
            AdSize.SMART_BANNER
    );

    private static final String LOG_TAG                 = AdsAdmob.class.getName();

    private Activity mContext                         = null;

    private boolean bDebug                              = true;

    private AdSize _bannerAdSize = null;
    protected AdView adView = null;

    /** Write access in UI thread (interstitial ad listener), read access in Cocos thread. */
    protected AtomicBoolean _isInterstitialAdLoaded = new AtomicBoolean(false);
    private AtomicBoolean _isIntestitialAdCreated = new AtomicBoolean(false);
    private InterstitialAd _interstitialAd = null;
    private String _interstitialId = null;

    /** Write access in UI thread (reward ad listener), read access in Cocos thread. */
    protected AtomicBoolean _isRewardedVideoAdLoaded = new AtomicBoolean(false);
    protected boolean _isRewardedVideoAdLoading = false;
    private RewardedVideoAd _rewardedVideoAd = null;

    private AtomicBoolean _isNativeExpressAdInitializing = new AtomicBoolean(false);
    private AdSize _nativeExpressAdSize = null;
    private NativeExpressAdView _nativeExpressAdView = null;

    private AtomicBoolean _isAdColonyInitializing = new AtomicBoolean(false);
    private AtomicBoolean _isAdColonyInitialized = new AtomicBoolean(false);
    private String _adColonyAppId = null;
    private String _adColonyInterstitialZoneId = null;
    private String _adColonyRewardedZoneId = null;
    private String _adColonyClientOptions = null;

    private String mBannerID        = "";
    private Set<String> mTestDevices = null;

    protected void logE(String msg) {
        Log.e(LOG_TAG, msg);
    }

    protected void logE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
    }

    protected void logI(String msg) {
        Log.i(LOG_TAG, msg);
    }

    protected void logD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public AdsAdmob(Context context) {
        logI("constructor: begin.");

        mContext = (Activity) context;
        PluginWrapper.addListener(this);

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

    @Deprecated
    private void initializeMediationAd() {
        logE("initializeMediationAd: this method is deprecated!");
    }

    public void configMediationAdColony(final JSONObject devInfo) {
        logD("configMediationAdColony: json = " + devInfo);

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
            PackageInfo info = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
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
                _adColonyAppId = devInfo.getString(AdColonyAppIdKey);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if (_adColonyAppId != null) {
                final List<String> zoneIds = new ArrayList<>();

                try {
                    _adColonyInterstitialZoneId = devInfo.getString(AdColonyInterstitialAdIdKey);
                    zoneIds.add(_adColonyInterstitialZoneId);
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                try {
                    _adColonyRewardedZoneId = devInfo.getString(AdColonyRewardedAdIdKey);
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

                            AdColony.configure(mContext, _adColonyClientOptions, _adColonyAppId,
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
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        logD("configDeveloperInfo");
        try {
            mBannerID       = devInfo.get(Constants.AdIdKey);
            _interstitialId = devInfo.get(Constants.AdIntestitialIdKey);
            logD("id banner Ad: " + mBannerID);
            logD("id interstitialAd: " + _interstitialId);
        } catch (Exception e) {
            logE("initAppInfo, The format of appInfo is wrong", e);
        }
    }

    @Override
    public void showAds(final Hashtable<String, String> info, final int pos) {
        final String strType = info.get(Constants.AdTypeKey);
        final int adsType = Integer.parseInt(strType);


        switch (adsType) {
            case AdType.Banner: {
                hideBannerAd();
                String strSize = info.get(Constants.AdSizeKey);
                int sizeEnum = Integer.parseInt(strSize);
                showBannerAd(sizeEnum, pos);
                break;
            }
            case AdType.Interstitial: {
                showInterstitial();
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

    private synchronized void showBannerAd(final int sizeEnum, final int pos) {
        logD("[ADS] ADSADMOB - SHOW BANNER AD");
        _bannerAdSize = AdSizes.get(sizeEnum);

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                adView = new AdView(mContext);
                adView.setAdSize(_bannerAdSize);
                adView.setAdUnitId(mBannerID);
                adView.setAdListener(new BannerAdListener(AdsAdmob.this));

                AdRequest.Builder builder = new AdRequest.Builder();

                if (mTestDevices != null) {
                    for (String mTestDevice : mTestDevices) {
                        builder.addTestDevice(mTestDevice);
                    }
                }

                adView.loadAd(builder.build());
                AdsWrapper.addAdView(adView, pos);

                logD("[ADS] ADSADMOB - SHOW BANNER AD DONE");
            }
        });
    }

    private void hideBannerAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (null != adView) {
                    adView.setVisibility(View.GONE);
                    adView.destroy();
                    adView = null;
                }
            }
        });
    }

    public void addTestDevice(final String deviceID) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("addTestDevice invoked : " + deviceID);
                if (null == mTestDevices) {
                    mTestDevices = new HashSet<>();
                }
                mTestDevices.add(deviceID);
            }
        });
    }

    private synchronized void createInterstitialAd() {
        logD("createInterstitialAd: begin.");

        if (!_isIntestitialAdCreated.get() ||
            !TextUtils.equals(_interstitialAd.getAdUnitId(), _interstitialId)) {
            // Only loadAd and creating AdRequest must perform on UI Thread.
            // https://groups.google.com/forum/#!topic/google-admob-ads-sdk/a342zlMTax0
            _interstitialAd = new InterstitialAd(mContext);

            _interstitialAd.setAdUnitId(_interstitialId);
            _interstitialAd.setAdListener(new InterstitialAdListener(this, _interstitialAd));
            _interstitialAd.setInAppPurchaseListener(new IAPListener(this));

            _isIntestitialAdCreated.set(true);
        }

        logD("createInterstitialAd: end.");
    }

    public synchronized void loadInterstitial() {
        logD("loadInterstitial: begin.");

        createInterstitialAd();

        Runnable r = new Runnable() {
            @Override
            public void run() {
                logD("loadInterstitial: main thread begin.");

                AdRequest.Builder builder = new AdRequest.Builder();

                if (_isAdColonyInitialized.get() && _adColonyInterstitialZoneId != null) {
                    AdColonyBundleBuilder.setZoneId(_adColonyInterstitialZoneId);
                    builder.addNetworkExtrasBundle(AdColonyAdapter.class, AdColonyBundleBuilder.build());
                }

                if (mTestDevices != null) {
                    for (String mTestDevice : mTestDevices) {
                        builder.addTestDevice(mTestDevice);
                    }
                }

                //begin load interstitial ad
                if (_interstitialAd != null) {
                    _interstitialAd.loadAd(builder.build());
                }

                logD("loadInterstitial: main thread end.");
            }
        };

        if (Looper.myLooper() == Looper.getMainLooper()) {
            // Run immediately if showing interstitial fails.
            r.run();
        } else {
            PluginWrapper.runOnMainThread(r);
        }

        logD("loadInterstitial: end.");
    }

    public synchronized void showInterstitial() {
        logD("showInterstitial: begin.");

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                logD("showInterstitial: main thread begin.");

                if (!_isIntestitialAdCreated.get()) {
                    logE("showInterstitial: interstitial has not been created!");
                    loadInterstitial();
                } else if (!_interstitialAd.isLoaded()) {
                    logE("showInterstitial: interstitial is not loaded!");
                    loadInterstitial();
                } else {
                    _interstitialAd.show();
                }

                logD("showInterstitial: main thread end.");
            }
        });

        logD("showInterstitial: end.");
    }

    public int getBannerWidthInPixel() {
        return _bannerAdSize.getWidthInPixels(mContext);
    }


    public int getBannerHeightInPixel() {
        return _bannerAdSize.getHeightInPixels(mContext);
    }

    @Override
    public String getPluginVersion() {
        return "0.2.0";
    }

    @Override
    public void queryPoints() {
        logD("Admob not support query points!");
    }

    public boolean hasInterstitial() {
        return _isInterstitialAdLoaded.get();
    }

    public boolean hasRewardedAd() {
        return _isRewardedVideoAdLoaded.get();
    }

    private void createRewardedAd() {
        assert (Looper.getMainLooper() == Looper.myLooper());

        if (_rewardedVideoAd == null) {
            _rewardedVideoAd = MobileAds.getRewardedVideoAdInstance(mContext);
            _rewardedVideoAd.setRewardedVideoAdListener(
                new RewardedAdListener(AdsAdmob.this, _rewardedVideoAd));
        }
    }

    public synchronized void loadRewardedAd(final String rewardedAdId) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (!_isRewardedVideoAdLoading) {
                    _isRewardedVideoAdLoading = true;
                    Bundle extras = new Bundle();
                    extras.putBoolean("_noRefresh", true);

                    AdRequest.Builder builder = new AdRequest.Builder();

                    if (_isAdColonyInitialized.get() && _adColonyRewardedZoneId != null) {
                        AdColonyBundleBuilder.setZoneId(_adColonyRewardedZoneId);
                        builder.addNetworkExtrasBundle(AdMobAdapter.class, extras)
                            .addNetworkExtrasBundle(AdColonyAdapter.class,
                                AdColonyBundleBuilder.build());
                    }

                    createRewardedAd();

                    AdRequest request = builder.build();
                    _rewardedVideoAd.loadAd(rewardedAdId, request);
                }
            }
        });
    }

    public synchronized void showRewardedAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                _rewardedVideoAd.show();
            }
        });
    }

    private void _showNativeExpressAd(@NonNull final String adUnitId,
                                      @NonNull final Integer width,
                                      @NonNull final Integer height,
                                      @NonNull final Integer position) {
        logD(String.format(Locale.getDefault(),
            "_showNativeExpressAd: begin adUnitId = %s width = %d height = %d position = %d.",
            adUnitId, width, height, position));


        if (!_isNativeExpressAdInitializing.getAndSet(true)) {
            _nativeExpressAdSize = new AdSize(width, height);

            PluginWrapper.runOnMainThread(new Runnable() {
                @Override
                public void run() {
                    logD("_showNativeExpressAd: main thread begin.");

                    hideNativeExpressAd();

                    assert (_nativeExpressAdView == null);
                    NativeExpressAdView view = new NativeExpressAdView(mContext);
                    view.setAdSize(_nativeExpressAdSize);
                    view.setAdUnitId(adUnitId);
                    view.setAdListener(new NativeExpressAdListener(AdsAdmob.this, view));

                    AdRequest.Builder builder = new AdRequest.Builder();

                    if (mTestDevices != null) {
                        for (String deviceId : mTestDevices) {
                            builder.addTestDevice(deviceId);
                        }
                    }

                    AdRequest request = builder.build();
                    view.loadAd(request);

                    AdsWrapper.addAdView(view, position);

                    _nativeExpressAdView = view;
                    _isNativeExpressAdInitializing.set(false);

                    logD("_showNativeExpressAd: main thread end.");
                }
            });
        } else {
            logD("_showNativeExpressAd: ad initialization has not been completed!");
        }

        logD("_showNativeExpressAd: end.");
    }

    public void showNativeExpressAd(@NonNull JSONObject json) {
        logD("showNativeExpressAd: begin json = " + json);

        assert (json.length() == 4);

        try {
            String adUnitId = json.getString("Param1");
            Integer width = json.getInt("Param2");
            Integer height = json.getInt("Param3");
            Integer position = json.getInt("Param4");

            _showNativeExpressAd(adUnitId, width, height, position);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        logD("showNativeExpressAd: end.");
    }

    public void hideNativeExpressAd() {
        logD("hideNativeExpressAd: begin.");

        Runnable r = new Runnable() {
            @Override
            public void run() {
                logD("hideNativeExpressAd: main thread begin.");
                if (_nativeExpressAdView != null) {
                    _nativeExpressAdView.setVisibility(View.GONE);
                    _nativeExpressAdView.destroy();
                    _nativeExpressAdView = null;
                }
                logD("hideNativeExpressAd: main thread end.");
            }
        };

        if (Looper.myLooper() == Looper.getMainLooper()) {
            r.run();
        } else {
            PluginWrapper.runOnMainThread(r);
        }

        logD("hideNativeExpressAd: end.");
    }

    public int _getSizeInPixels(@NonNull Integer size) {
        if (size == AdSize.AUTO_HEIGHT) {
            return getAutoHeightInPixels();
        }
        if (size == AdSize.FULL_WIDTH) {
            return getFullWidthInPixels();
        }
        AdSize adSize = new AdSize(size, size);
        return adSize.getHeightInPixels(mContext);
    }

    public int getSizeInPixels(int size) {
        return _getSizeInPixels(size);
    }

    public int getAutoHeightInPixels() {
        return AdSize.SMART_BANNER.getHeightInPixels(mContext);
    }

    public int getFullWidthInPixels() {
        return AdSize.SMART_BANNER.getWidthInPixels(mContext);
    }

    public synchronized void slideBannerUp() {
        Log.i(LOG_TAG, "Slide Banner Up: CALL");

        if (adView == null) {
            Log.i(LOG_TAG, "Slide Banner Up: NO VIEW");
        }

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (adView != null) {
                    adView.setVisibility(View.INVISIBLE);
                    TranslateAnimation anim = new TranslateAnimation(Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 1, Animation.RELATIVE_TO_PARENT, 0);
                    anim.setDuration(1000);
                    anim.setFillAfter(true);

                    anim.setAnimationListener(new Animation.AnimationListener() {
                        @Override
                        public void onAnimationStart(Animation animation) {
                            Log.i(LOG_TAG, "Slide Banner Up: START");
                            if (adView != null) {
                                adView.setVisibility(View.VISIBLE);
                            }
                        }

                        @Override
                        public void onAnimationEnd(Animation animation) {
                            Log.i(LOG_TAG, "Slide Banner Up: END");
                        }

                        @Override
                        public void onAnimationRepeat(Animation animation) {
                        }
                    });
                    adView.startAnimation(anim);
                }
            }
        });
    }

    public synchronized void slideBannerDown() {
        Log.i(LOG_TAG, "Slide Banner Down: CALL");

        if (adView == null) {
            Log.i(LOG_TAG, "Slide Banner Down: NO VIEW");
            return;
        }

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (adView != null) {
                    adView.setVisibility(View.VISIBLE);
                    TranslateAnimation anim = new TranslateAnimation(Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 1);
                    anim.setDuration(1000);
                    anim.setFillAfter(true);

                    anim.setAnimationListener(new Animation.AnimationListener() {
                        @Override
                        public void onAnimationStart(Animation animation) {
                            Log.i(LOG_TAG, "Slide Banner Down: START");
                        }

                        @Override
                        public void onAnimationEnd(Animation animation) {
                            Log.i(LOG_TAG, "Slide Banner Down: END");
                            adView.setVisibility(View.GONE);
                        }

                        @Override
                        public void onAnimationRepeat(Animation animation) {
                        }
                    });

                    adView.startAnimation(anim);
                }
            }
        });
    }
}
