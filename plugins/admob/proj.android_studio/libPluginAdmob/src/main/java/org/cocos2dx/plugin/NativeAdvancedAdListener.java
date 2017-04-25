package org.cocos2dx.plugin;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.formats.NativeAdView;
import com.google.android.gms.ads.formats.NativeAppInstallAd;
import com.google.android.gms.ads.formats.NativeContentAd;

/**
 * Created by ndpduc on 4/21/17.
 */

public class NativeAdvancedAdListener extends AdListener implements
            NativeAppInstallAd.OnAppInstallAdLoadedListener,
            NativeContentAd.OnContentAdLoadedListener {
    private static final String _Tag = NativeAdvancedAdListener.class.getName();

    private NativeCallback _callback;
    private NativeAdView _view;

    NativeAdvancedAdListener(@NonNull NativeCallback callback, @NonNull NativeAdView view) {
        _callback = callback;
        _view = view;
    }

    private void logD(String message) {
        Log.d(_Tag, message);
    }

    private void logE(String message) {
        Log.e(_Tag, message);
    }

    @Override
    public void onAppInstallAdLoaded(NativeAppInstallAd ad) {
        logD("onAppInstallAdLoaded: begin.");
        _callback.onEvent(AdsWrapper.ResultCode.NativeAdvancedAdReceived, "Native express ad loaded");
        logD("onAppInstallAdLoaded: end.");
    }

    @Override
    public void onContentAdLoaded(NativeContentAd ad) {
        logD("onContentAdLoaded: begin.");
        _callback.onEvent(AdsWrapper.ResultCode.NativeAdvancedAdReceived, "Native express ad loaded");
        logD("onContentAdLoaded: end.");
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
        _callback.onEvent(AdsWrapper.ResultCode.NativeAdvancedAdFailedToLoad, errorDescription);
        logD("onAdFailedToLoad: end.");
    }
}
