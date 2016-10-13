package org.cocos2dx.plugin;

import android.graphics.Color;
import android.view.View;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

/**
 * Created by enrevol on 4/8/16.
 */
class BannerAdListener extends AdListener {
    private AdsAdmob _adapter;

    BannerAdListener(AdsAdmob adapter) {
        this._adapter = adapter;
    }

    @Override
    public void onAdLoaded() {
        _adapter.logD("BannerAdListener: onAdLoaded: begin.");

        super.onAdLoaded();
        AdsWrapper.onAdsResult(_adapter, ResultCode.BannerAdLoaded, "Banner ad loaded");

        if (_adapter._hasBannerAd()) {
            _adapter._bannerAdView.setVisibility(View.GONE);
            _adapter._bannerAdView.setVisibility(View.VISIBLE);

            if (_adapter._bannerAdView.getAdSize().isAutoHeight()) {
                _adapter.logD("AdSize is SMART BANNER. Set its background color BLACK");
                _adapter._bannerAdView.setBackgroundColor(Color.BLACK);
            }
        }

        _adapter.logD("BannerAdListener: onAdLoaded: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        _adapter.logE("BannerAdListener: onAdFailedToLoad: begin errorCode = " + errorCode);

        String errorMsg = "Unknown error";
        switch (errorCode) {
        case AdRequest.ERROR_CODE_NETWORK_ERROR:
            errorMsg = "Network error";
            break;
        case AdRequest.ERROR_CODE_INVALID_REQUEST:
            errorMsg = "The ad request is invalid";
            break;
        case AdRequest.ERROR_CODE_NO_FILL:
            errorMsg =
                "The ad request is successful, but no ad was returned due to lack of ad inventory.";
            break;
        default:
            break;
        }
        _adapter.logE("Error message: " + errorMsg);

        super.onAdFailedToLoad(errorCode);
        AdsWrapper.onAdsResult(_adapter, ResultCode.BannerAdFailedToLoad, errorMsg);

        _adapter.logD("BannerAdListener: onAdFailedToLoad: end.");
    }

    @Override
    public void onAdOpened() {
        _adapter.logD("BannerAdListener: onAdOpened: begin.");

        super.onAdOpened();
        AdsWrapper.onAdsResult(_adapter, ResultCode.BannerAdOpened, "Banner ad opened");

        _adapter.logD("BannerAdListener: onAdOpened: end.");
    }

    @Override
    public void onAdClosed() {
        _adapter.logD("BannerAdListener: onAdClosed: begin");

        super.onAdClosed();
        AdsWrapper.onAdsResult(_adapter, ResultCode.BannerAdClosed, "Banner ad closed");

        _adapter.logD("BannerAdListener: onAdClosed: end.");
    }


    @Override
    public void onAdLeftApplication() {
        _adapter.logD("BannerAdListener: onLeftApplication: begin.");

        super.onAdLeftApplication();
        AdsWrapper.onAdsResult(_adapter, ResultCode.BannerAdLeftApplication,
            "Banner ad left application");

        _adapter.logD("BannerAdListener: onLeftApplication: end.");
    }
}