package org.cocos2dx.plugin;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.InterstitialAd;

import java.lang.ref.WeakReference;

/**
 * Created by enrevol on 4/8/16.
 */
class InterstitialAdListener extends AdListener {
    private AdsAdmob _adapter;
    private WeakReference<InterstitialAd> _interstitialAd;

    public InterstitialAdListener(AdsAdmob adapter, InterstitialAd ad) {
        _adapter = adapter;
        _interstitialAd = new WeakReference<>(ad);
    }

    private void refreshAdAvailability() {
        assert (_interstitialAd.get() != null);

        if (_interstitialAd.get() != null) {
            _adapter._changeInterstitialAdAvailability(_interstitialAd.get().isLoaded());
        }
    }

    @Override
    public void onAdClosed() {
        _adapter.logD("InterstitialAdListener: onAdClosed: begin.");

        super.onAdClosed();
        _adapter.loadInterstitial();
        refreshAdAvailability();

        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsClosed, "[ADS] - AdWrapper Closed");

        _adapter.logD("InterstitialAdListener: onAdClosed: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        _adapter.logD("InterstitialAdListener: onAdFailedToLoad: begin.");
        _adapter.logE("InterstitialAdListener: onAdFailedToLoad: errorCode = " + errorCode);

        super.onAdFailedToLoad(errorCode);
        refreshAdAvailability();

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

        _adapter.logD("InterstitialAdListener: onAdFailedToLoad: end.");
    }

    @Override
    public void onAdLeftApplication() {
        _adapter.logD("InterstitialAdListener: onAdLeftApplication: begin.");

        super.onAdLeftApplication();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsDismissed, "[ADS] - AdWrapper Dismissed");

        _adapter.logD("InterstitialAdListener: onAdLeftApplication: end.");
    }

    @Override
    public void onAdOpened() {
        _adapter.logD("InterstitialAdListener: onAdLeftApplication: begin.");

        super.onAdOpened();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsShown, "Ads view shown!");

        _adapter.logD("InterstitialAdListener: onAdLeftApplication: end.");
    }

    @Override
    public void onAdLoaded() {
        _adapter.logD("InterstitialAdListener: onAdLoaded begin.");

        super.onAdLoaded();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.RESULT_CODE_AdsInterstitialReceived, "Ads request received success!");

        _adapter.logD("InterstitialAdListener: onAdLoaded end.");
    }
}