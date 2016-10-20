package org.cocos2dx.plugin;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

/**
 * Created by enrevol on 4/8/16.
 */
class InterstitialAdListener extends AdListener {
    private static final String _Tag = InterstitialAdListener.class.getName();

    private NativeCallback _callback;

    InterstitialAdListener(@NonNull NativeCallback callback) {
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
        _callback.onEvent(ResultCode.InterstitialAdLoaded, "Interstitial ad loaded");
        logD("onAdLoaded: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        logE("onAdFailedToLoad: begin errorCode = " + errorCode);

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
        _callback.onEvent(ResultCode.InterstitialAdFailedToLoad, errorMsg);
        logD("onAdFailedToLoad: end.");
    }

    @Override
    public void onAdOpened() {
        logD("onAdLeftApplication: begin.");
        _callback.onEvent(ResultCode.InterstitialAdOpened, "Interstitial ad opened");
        logD("onAdLeftApplication: end.");
    }

    @Override
    public void onAdClosed() {
        logD("onAdClosed: begin.");
        _callback.onEvent(ResultCode.InterstitialAdClosed, "Interstitial ad closed");
        logD("onAdClosed: end.");
    }

    @Override
    public void onAdLeftApplication() {
        logD("onAdLeftApplication: begin.");
        _callback.onEvent(ResultCode.InterstitialAdLeftApplication,
            "Interstitial ad left application");
        logD("onAdLeftApplication: end.");
    }
}