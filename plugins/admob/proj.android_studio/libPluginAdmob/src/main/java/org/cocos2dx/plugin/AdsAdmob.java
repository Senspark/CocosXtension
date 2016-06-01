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
import android.os.Bundle;
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
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.jirbo.adcolony.AdColony;
import com.jirbo.adcolony.AdColonyAdapter;
import com.jirbo.adcolony.AdColonyBundleBuilder;

import org.json.JSONObject;

import java.util.Arrays;
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
        AdColony.resume(mContext);
    }

    @Override
    public void onPause() {
        AdColony.pause();
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

    private static final String LOG_TAG                 = "AdsAdmob";

    protected Activity mContext                         = null;
    protected static AdsAdmob mAdapter                  = null;

    private boolean bDebug                              = true;

    protected AdView adView                             = null;
    private InterstitialAd interstitialAdView           = null;
    private RewardedVideoAd mRewardedVideoAd            = null;
    private boolean isLoaded                            = false;
    protected boolean mIsRewardedVideoLoading;
    protected final Object mLock = new Object();

    private int mBannerWidthInPixel = 0;
    private int mBannerHeightInPixel = 0;

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
        return "8.4.0";
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
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Log.i(LOG_TAG, "Config Mediation for AdColony");
                try {
                    PackageInfo pInfo       = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
                    String versionName      = pInfo.versionName;
                    String mClientOptions   = String.format("version:" + versionName + ",store:google");

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
        });
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
    public void showAds(Hashtable<String, String> info, int pos) {
        try {
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

    @Override
    public void spendPoints(int points) {
        logD("Admob not support spend points!");
    }

    @Override
    public void hideAds(Hashtable<String, String> info) {
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
        adView = new AdView(mContext);

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                final List<AdSize> AdSizes = Arrays.asList(
                    AdSize.BANNER,
                    AdSize.LARGE_BANNER,
                    AdSize.MEDIUM_RECTANGLE,
                    AdSize.FULL_BANNER,
                    AdSize.LEADERBOARD,
                    AdSize.WIDE_SKYSCRAPER,
                    AdSize.SMART_BANNER
                );

                AdSize size = AdSizes.get(sizeEnum);
                adView.setAdSize(size);
                adView.setAdUnitId(mBannerID);

                AdRequest.Builder builder = new AdRequest.Builder();

                try {
                    if (mTestDevices != null) {
                        for (String mTestDevice : mTestDevices) {
                            builder.addTestDevice(mTestDevice);
                        }
                    }
                } catch (Exception e) {
                    logE("Error during add test device", e);
                }

                adView.loadAd(builder.build());
                adView.setAdListener(new BannerAdListener(AdsAdmob.this));

                AdsWrapper.addAdView(adView, pos);
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

    public void loadInterstitial() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Log.i(LOG_TAG, "Start loading interstitial ad");
                interstitialAdView = new InterstitialAd(mContext);
                interstitialAdView.setAdUnitId(mInterstitialID);
                interstitialAdView.setAdListener(new InterstitialAdListener(AdsAdmob.this));
                interstitialAdView.setInAppPurchaseListener(new IAPListener(AdsAdmob.this));

                AdRequest.Builder builder = new AdRequest.Builder();
                AdColonyBundleBuilder.setZoneId(mAdColonyInterstitialZoneID);
                builder.addNetworkExtrasBundle(AdColonyAdapter.class, AdColonyBundleBuilder.build());

                if (mTestDevices != null) {
                    for (String mTestDevice : mTestDevices) {
                        builder.addTestDevice(mTestDevice);
                    }
                }

                //begin load interstitial ad
                interstitialAdView.loadAd(builder.build());
            }
        });
    }

    public void showInterstitial() {
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

    public synchronized int getBannerWidthInPixel() {
        mBannerWidthInPixel = 0;
        mShouldLock = true;

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (adView != null && mContext != null)
                    mBannerWidthInPixel = adView.getAdSize().getWidthInPixels(mContext);

                synchronized (AdsAdmob.this) {
                    mShouldLock = false;
                    AdsAdmob.this.notify();
                }
            }
        });

        synchronized (this) {
            try {
                if (mShouldLock) {
                    wait();
                }
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }

        return mBannerWidthInPixel;
    }


    public synchronized int getBannerHeightInPixel() {
        mBannerHeightInPixel = 0;
        mShouldLock = true;

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (adView != null && mContext != null)
                    mBannerHeightInPixel = adView.getAdSize().getHeightInPixels(mContext);

                synchronized (AdsAdmob.this) {
                    mShouldLock = false;
                    AdsAdmob.this.notify();
                }
            }
        });

        synchronized (this) {
            try {
                if (mShouldLock) {
                    wait();
                }
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
        }

        return mBannerHeightInPixel;
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

        synchronized (this) {
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
                    AdsAdmob.this.notify();
                }
            }
        });

        synchronized (this) {
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

    public void showRewardedAd() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                mRewardedVideoAd.show();
            }
        });
    }

    public void slideBannerUp() {
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

    public void slideBannerDown() {
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
