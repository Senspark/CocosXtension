package org.cocos2dx.plugin;

import android.graphics.Color;
import android.view.View;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

/**
 * Created by enrevol on 4/8/16.
 */
class BannerAdListener extends AdListener {
    private AdsAdmob _adapter;

    BannerAdListener(AdsAdmob adapter) {
        this._adapter = adapter;
    }

    @Override
    public void onAdClosed() {
        _adapter.logD("BannerAdListener: onAdClosed: begin");

        super.onAdClosed();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsClosed, "Ads view closed!");

        _adapter.logD("BannerAdListener: onAdClose: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        _adapter.logD("BannerAdListener: onAdFailedToLoad: begin.");
        _adapter.logE("load interstitial failed error code " + errorCode);

        super.onAdFailedToLoad(errorCode);

        int errorNo = AdsWrapper.RESULT_CODE_AdsUnknownError;
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
        _adapter.logD("failed to receive ad : " + errorNo + " , " + errorMsg);
        AdsWrapper.onAdsResult(_adapter, errorNo, errorMsg);

        _adapter.logD("BannerAdListener: onAdFailedToLoad: end.");
    }

    @Override
    public void onAdLeftApplication() {
        _adapter.logD("BannerAdListener: onLeftApplication: begin.");

        super.onAdLeftApplication();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Ads view dismissed!");

        _adapter.logD("BannerAdListener: onLeftApplication: end.");
    }

    @Override
    public void onAdOpened() {
        _adapter.logD("BannerAdListener: onAdOpened: begin.");

        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsShown, "Ads view shown!");
        super.onAdOpened();

        _adapter.logD("BannerAdListener: onAdOpened: end.");
    }

    @Override
    public void onAdLoaded() {
        _adapter.logD("BannerAdListener: onAdLoaded: begin.");

        super.onAdLoaded();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsBannerReceived, "Ads request received success!");

        if (_adapter.adView != null) {
            _adapter.adView.setVisibility(View.GONE);
            _adapter.adView.setVisibility(View.VISIBLE);

            if (_adapter.adView.getAdSize().isAutoHeight()) {
                _adapter.logD("AdSize is SMART BANNER. Set its background color BLACK");
                _adapter.adView.setBackgroundColor(Color.BLACK);
            }
        }

        _adapter.logD("BannerAdListener: onAdLoaded: end.");
    }
}