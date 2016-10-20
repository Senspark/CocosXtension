package org.cocos2dx.plugin;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

/**
 * Created by enrevol on 4/8/16.
 */
class BannerAdListener extends AdListener {
    private static final String _Tag = BannerAdListener.class.getName();

    private NativeCallback _callback;

    BannerAdListener(@NonNull NativeCallback callback) {
        _callback = callback;
    }

    private void logD(String message) {
        Log.d(_Tag, message);
    }

    private void logE(String message) {
        Log.e(_Tag, message);
    }

    @Override
    public void onAdLoaded() {
        logD("onAdLoaded: begin.");
        _callback.onEvent(ResultCode.BannerAdLoaded, "Banner ad loaded");
        logD("onAdLoaded: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        logE("BannerAdListener: onAdFailedToLoad: begin errorCode = " + errorCode);

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
        logE("Error message: " + errorMsg);
        _callback.onEvent(ResultCode.BannerAdFailedToLoad, errorMsg);
        logD("BannerAdListener: onAdFailedToLoad: end.");
    }

    @Override
    public void onAdOpened() {
        logD("BannerAdListener: onAdOpened: begin.");
        _callback.onEvent(ResultCode.BannerAdOpened, "Banner ad opened");
        logD("BannerAdListener: onAdOpened: end.");
    }

    @Override
    public void onAdClosed() {
        logD("BannerAdListener: onAdClosed: begin");
        _callback.onEvent(ResultCode.BannerAdClosed, "Banner ad closed");
        logD("BannerAdListener: onAdClosed: end.");
    }


    @Override
    public void onAdLeftApplication() {
        logD("BannerAdListener: onLeftApplication: begin.");
        _callback.onEvent(ResultCode.BannerAdLeftApplication, "Banner ad left application");
        logD("BannerAdListener: onLeftApplication: end.");
    }
}