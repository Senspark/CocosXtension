package org.cocos2dx.plugin;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

/**
 * Created by Zinge on 6/22/16.
 */
class NativeExpressAdListener extends AdListener {
    private static final String _Tag = NativeExpressAdListener.class.getName();

    private NativeCallback _callback;

    NativeExpressAdListener(@NonNull NativeCallback callback) {
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
        _callback.onEvent(ResultCode.NativeExpressAdLoaded, "Native express ad loaded");
        logD("onAdLoaded: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        logE("onAdFailedToLoad: begin errorCode = " + errorCode);

        String errorDescription = "Unknown error";
        switch (errorCode) {
        case AdRequest.ERROR_CODE_NETWORK_ERROR:
            errorDescription = "Network error";
            break;
        case AdRequest.ERROR_CODE_INVALID_REQUEST:
            errorDescription = "The ad request is invalid";
            break;
        case AdRequest.ERROR_CODE_NO_FILL:
            errorDescription =
                "The ad request is successful, but no ad was returned due to lack of ad inventory.";
            break;
        default:
            break;
        }
        logE("onAdFailedToLoad errorDescription = " + errorDescription);
        _callback.onEvent(ResultCode.NativeExpressAdFailedToLoad, errorDescription);
        logD("onAdFailedToLoad: end.");
    }

    @Override
    public void onAdOpened() {
        logD("onAdOpened: begin.");
        _callback.onEvent(ResultCode.NativeExpressAdOpened, "Ads view shown!");
        logD("onAdOpened: end.");
    }

    @Override
    public void onAdClosed() {
        logD("onAdClosed: begin.");
        _callback.onEvent(ResultCode.NativeExpressAdClosed, "Ads view closed!");
        logD("onAdClosed: end.");
    }

    @Override
    public void onAdLeftApplication() {
        logD("onAdLeftApplication: begin.");
        _callback.onEvent(ResultCode.NativeExpressAdLeftApplication, "Ads left application!");
        logD("onAdLeftApplication: end.");
    }
}
