package org.cocos2dx.plugin;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.InterstitialAd;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

import java.lang.ref.WeakReference;

/**
 * Created by enrevol on 4/8/16.
 */
class InterstitialAdListener extends AdListener {
    private AdsAdmob                      _adapter;
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
    public void onAdLoaded() {
        _adapter.logD("InterstitialAdListener: onAdLoaded: begin.");

        super.onAdLoaded();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.InterstitialAdLoaded, "Interstitial ad loaded");

        _adapter.logD("InterstitialAdListener: onAdLoaded: end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        _adapter.logE("InterstitialAdListener: onAdFailedToLoad: begin errorCode = " + errorCode);

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
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.InterstitialAdFailedToLoad, errorMsg);

        _adapter.logD("InterstitialAdListener: onAdFailedToLoad: end.");
    }

    @Override
    public void onAdOpened() {
        _adapter.logD("InterstitialAdListener: onAdLeftApplication: begin.");

        super.onAdOpened();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.InterstitialAdOpened, "Interstitial ad opened");

        _adapter.logD("InterstitialAdListener: onAdLeftApplication: end.");
    }

    @Override
    public void onAdClosed() {
        _adapter.logD("InterstitialAdListener: onAdClosed: begin.");

        super.onAdClosed();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.InterstitialAdClosed, "Interstitial ad closed");

        // Should be removed?
        _adapter.loadInterstitial();

        _adapter.logD("InterstitialAdListener: onAdClosed: end.");
    }

    @Override
    public void onAdLeftApplication() {
        _adapter.logD("InterstitialAdListener: onAdLeftApplication: begin.");

        super.onAdLeftApplication();
        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.InterstitialAdLeftApplication,
            "Interstitial ad left application");

        _adapter.logD("InterstitialAdListener: onAdLeftApplication: end.");
    }
}