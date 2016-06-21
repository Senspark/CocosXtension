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

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
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

import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.List;
import java.util.Set;

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
        return true;
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

    private static final String LOG_TAG                 = "AdsAdmob";

    protected Activity mContext                         = null;
    protected static AdsAdmob mAdapter                  = null;

    private boolean bDebug                              = true;

    protected AdView adView                             = null;
    protected InterstitialAd interstitialAdView           = null;
    private RewardedVideoAd mRewardedVideoAd            = null;
    private boolean isLoaded                            = false;
    protected boolean mIsRewardedVideoLoading;
    protected final Object mLock = new Object();

    private AdSize  mBannerSize                         = null;

    private NativeExpressAdView _nativeExpressAdView = null;

    private String mAdColonyAppID = "";
    private String mAdColonyInterstitialZoneID = "";
    private String mAdColonyRewardedZoneID = "";
    private String mAdColonyClientOption = "";

    private String mBannerID        = "";
    private String mInterstitialID  = "";
    private Set<String> mTestDevices = null;

    private volatile boolean mShouldLock = false;

    protected void logE(String msg) {
        Log.e(LOG_TAG, msg);
    }

    protected void logE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
    }

    protected void logD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }

    public AdsAdmob(Context context) {
        Log.i(LOG_TAG, "Initializing AdsAdmob");

        mContext = (Activity) context;
        mAdapter = this;
        PluginWrapper.addListener(this);

    }

    @Override
    public void setDebugMode(boolean debug) {
        bDebug = debug;
    }

    @Override
    public String getSDKVersion() {
        return "9.0.0";
    }

    private void initializeMediationAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (mAdColonyAppID.equals("")) {
                    Log.e(LOG_TAG, "AdColony App ID is not set. Please set it if you want to use AdColony Rewarded Ad Mediation");
                } else {
                    AdColony.configure(mContext, mAdColonyClientOption, mAdColonyAppID, mAdColonyInterstitialZoneID, mAdColonyRewardedZoneID);
                }

                mRewardedVideoAd = MobileAds.getRewardedVideoAdInstance(mContext);
                mRewardedVideoAd.setRewardedVideoAdListener(new RewardedAdListener());
            }
        });
    }

    public void configMediationAdColony(final JSONObject devInfo) {
        Log.i(LOG_TAG, "Config Mediation for AdColony");
        try {
            PackageInfo pInfo       = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
            String versionName      = pInfo.versionName;
            String mClientOptions   = "version:" + versionName + ",store:google";
            String adcolonyAppID                = devInfo.getString("AdColonyAppID");
            String adcolonyInterstitialZoneID   = devInfo.getString("AdColonyInterstitialAdID");
            String adcolonyRewardedZoneID       = devInfo.getString("AdColonyRewardedAdID");

            mAdColonyAppID              = adcolonyAppID;
            mAdColonyInterstitialZoneID = adcolonyInterstitialZoneID;
            mAdColonyRewardedZoneID     = adcolonyRewardedZoneID;
            mAdColonyClientOption       = mClientOptions;

            Log.i(LOG_TAG, "### AdColony AppID: " + adcolonyAppID + " - InterstitialZoneID: " + adcolonyInterstitialZoneID + " - RewardedZoneID: " + adcolonyRewardedZoneID + " ClientOption: " + mClientOptions);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }



    @Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        logD("configDeveloperInfo");
        try {
            mBannerID       = devInfo.get(Constants.AdIdKey);
            mInterstitialID = devInfo.get(Constants.AdIntestitialIdKey);
            logD("id banner Ad: " + mBannerID);
            logD("id interstitialAd: " + mInterstitialID);
        } catch (Exception e) {
            logE("initAppInfo, The format of appInfo is wrong", e);
        }
    }

    @Override
    public void showAds(final Hashtable<String, String> info, final int pos) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {

                try {
                    if (null != adView) {
                        adView.setVisibility(View.GONE);
                        adView.destroy();
                        adView = null;
                    }

                    String strType = info.get(Constants.AdTypeKey);
                    int adsType = Integer.parseInt(strType);

                    switch (adsType) {
                        case AdType.Banner: {
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
                } catch (Exception e) {
                    logE("Error when show Ads ( " + info.toString() + " )", e);
                }
            }
        });
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

        mBannerSize = AdSizes.get(sizeEnum);

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                adView = new AdView(mContext);
                adView.setAdSize(mBannerSize);
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

    public synchronized void loadInterstitial() {
        if (interstitialAdView == null || !TextUtils.equals(interstitialAdView.getAdUnitId(), mInterstitialID)) {
            interstitialAdView = new InterstitialAd(mContext);

            interstitialAdView.setAdUnitId(mInterstitialID);
            interstitialAdView.setAdListener(new InterstitialAdListener(AdsAdmob.this));
            interstitialAdView.setInAppPurchaseListener(new IAPListener(AdsAdmob.this));
        }

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Log.i(LOG_TAG, "Start loading interstitial ad");
                AdRequest.Builder builder = new AdRequest.Builder();
                AdColonyBundleBuilder.setZoneId(mAdColonyInterstitialZoneID);
                builder.addNetworkExtrasBundle(AdColonyAdapter.class, AdColonyBundleBuilder.build());


                if (mTestDevices != null) {
                    for (String mTestDevice : mTestDevices) {
                        builder.addTestDevice(mTestDevice);
                    }
                }

                //begin load interstitial ad
                if (interstitialAdView != null) {
                    interstitialAdView.loadAd(builder.build());
                }
            }
        });
    }

    public synchronized void showInterstitial() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (interstitialAdView == null || interstitialAdView.isLoaded() == false) {
                    Log.e("PluginAdmob", String.format("ADMOB: Interstitial cannot show. It is not ready: - InterstitialAdView: %s - isLoaded: %b",
                            interstitialAdView == null ? "null" : interstitialAdView.toString(),
                            interstitialAdView != null && interstitialAdView.isLoaded()));
                    loadInterstitial();
                } else {
                    interstitialAdView.show();
                }
            }
        });
    }

    public int getBannerWidthInPixel() {
        return mBannerSize.getWidthInPixels(mContext);
    }


    public int getBannerHeightInPixel() {
        return mBannerSize.getHeightInPixels(mContext);
    }

    @Override
    public String getPluginVersion() {
        return "0.2.0";
    }

    @Override
    public void queryPoints() {
        logD("Admob not support query points!");
    }

    public synchronized boolean hasInterstitial() {
        isLoaded = false;
        mShouldLock = true;

        synchronized (this) {

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                isLoaded = interstitialAdView.isLoaded();

                synchronized (AdsAdmob.this) {
                    mShouldLock = false;
                    AdsAdmob.this.notify();
                }
            }
        });


            try {
                if (mShouldLock) {
                    wait();
                }
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }

        return isLoaded;
    }

    public boolean hasRewardedAd() {
        isLoaded = false;
        mShouldLock = true;

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                isLoaded = mRewardedVideoAd.isLoaded();

                synchronized (AdsAdmob.this) {
                    mShouldLock = false;
                    logD("[ADS] NOTIFY");
                    AdsAdmob.this.notify();
                }
            }
        });

        synchronized (this) {
            try {
                if (mShouldLock) {
                    logD("[ADS] WAIT");
                    wait();
                }
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }
        return isLoaded;
    }

    public synchronized void loadRewardedAd(final String adID) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                synchronized (mLock) {
                    if (!mIsRewardedVideoLoading) {
                        mIsRewardedVideoLoading = true;
                        Bundle extras = new Bundle();
                        extras.putBoolean("_noRefresh", true);
                        AdColonyBundleBuilder.setZoneId(mAdColonyRewardedZoneID);
                        AdRequest adRequest = new AdRequest.Builder()
                                .addNetworkExtrasBundle(AdMobAdapter.class, extras)
                                .addNetworkExtrasBundle(AdColonyAdapter.class, AdColonyBundleBuilder.build())
                                .build();
                        mRewardedVideoAd.loadAd(adID, adRequest);
                    }
                }
            }
        });
    }

    public synchronized void showRewardedAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mRewardedVideoAd.show();
            }
        });
    }

    @SuppressLint("Assert")
    private NativeExpressAdView createNativeExpressAdView(@NonNull Integer sizeType,
                                                          @NonNull Integer width,
                                                          @NonNull Integer height) {
        assert (Looper.getMainLooper() == Looper.myLooper());
        AdSize adSize = null;

        switch (sizeType) {
            case 0: {
                adSize = new AdSize(width, height);
                break;
            }

            case 1:
            case 2: {
                adSize = new AdSize(AdSize.FULL_WIDTH, height);
                break;
            }
        }

        assert (adSize != null);

        NativeExpressAdView view = new NativeExpressAdView(mContext);
        view.setAdSize(adSize);
        return view;
    }

    private void _showNativeExpressAd(@NonNull final String adUnitId,
                                         @NonNull final Integer sizeType,
                                         @NonNull final Integer width,
                                         @NonNull final Integer height,
                                         @NonNull final Integer position) {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                hideNativeExpressAd();

                assert(_nativeExpressAdView == null);
                NativeExpressAdView view = createNativeExpressAdView(sizeType, width, height);
                view.setAdUnitId(adUnitId);

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
            }
        });
    }

    @SuppressLint("Assert")
    public void showNativeExpressAd(@NonNull HashMap<String, String> params) {
        assert (params.size() == 4);
        assert (params.containsKey("Param1"));
        assert (params.containsKey("Param2"));
        assert (params.containsKey("Param3"));
        assert (params.containsKey("Param4"));
        assert (params.containsKey("Param5"));

        String adUnitId = params.get("Param1");
        Integer sizeType = Integer.parseInt(params.get("Param2"));
        Integer width = Integer.parseInt(params.get("Param3"));
        Integer height = Integer.parseInt(params.get("Param4"));
        Integer position = Integer.parseInt(params.get("Param5"));

        _showNativeExpressAd(adUnitId, sizeType, width, height, position);
    }

    public void hideNativeExpressAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (_nativeExpressAdView != null) {
                    _nativeExpressAdView.setVisibility(View.GONE);
                    _nativeExpressAdView.destroy();
                    _nativeExpressAdView = null;
                }
            }
        });
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
