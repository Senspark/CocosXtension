package org.cocos2dx.plugin;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

/**
 * Created by enrevol on 4/8/16.
 */
class InterstitialAdListener extends AdListener {
    private AdsAdmob adapter;

    InterstitialAdListener(AdsAdmob adapter) {
        this.adapter = adapter;
    }

    @Override
    public void onAdClosed() {
        super.onAdClosed();
        adapter.loadInterstitial();
        adapter.logD("onDismissScreen invoked");
        AdsWrapper.onAdsResult(adapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Ads view dismissed!");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        adapter.logE("load interstitial failed error code " + errorCode);
        super.onAdFailedToLoad(errorCode);

        int errorNo = AdsWrapper.RESULT_CODE_UnknownError;
        String errorMsg = "Unknow error";
        switch (errorCode) {
            case AdRequest.ERROR_CODE_NETWORK_ERROR:
                errorNo = AdsWrapper.RESULT_CODE_NetworkError;
                errorMsg = "Network error";
                break;
            case AdRequest.ERROR_CODE_INVALID_REQUEST:
                errorNo = AdsWrapper.RESULT_CODE_NetworkError;
                errorMsg = "The ad request is invalid";
                break;
            case AdRequest.ERROR_CODE_NO_FILL:
                errorMsg = "The ad request is successful, but no ad was returned due to lack of ad inventory.";
                break;
            default:
                break;
        }
        adapter.logD("failed to receive ad : " + errorNo + " , " + errorMsg);
        AdsWrapper.onAdsResult(adapter, errorNo, errorMsg);
    }

    @Override
    public void onAdLeftApplication() {
        super.onAdLeftApplication();
        adapter.logD("onLeaveApplication invoked");
    }

    @Override
    public void onAdOpened() {
        adapter.logD("onPresentScreen invoked");
        AdsWrapper.onAdsResult(adapter, AdsWrapper.RESULT_CODE_AdsShown, "Ads view shown!");

        super.onAdOpened();
    }

    @Override
    public void onAdLoaded() {
        adapter.logD("onReceiveAd invoked");
        AdsWrapper.onAdsResult(adapter, AdsWrapper.RESULT_CODE_AdsInterstitialReceived, "Ads request received success!");

        super.onAdLoaded();
    }
}