package org.cocos2dx.plugin;

import android.os.Looper;
import android.support.annotation.NonNull;
import android.view.View;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.NativeExpressAdView;

import java.lang.ref.WeakReference;

/**
 * Created by Zinge on 6/22/16.
 */
public class NativeExpressAdListener extends AdListener {
    private AdsAdmob _adapter;
    private WeakReference<NativeExpressAdView> _nativeExpressAdView;

    public NativeExpressAdListener(@NonNull AdsAdmob adapter, @NonNull NativeExpressAdView adView) {
        this._adapter = adapter;
        this._nativeExpressAdView = new WeakReference<>(adView);
    }

    @Override
    public void onAdClosed() {
        _adapter.logD("NativeExpressAdListener: onAdClosed begin.");
        assert (Looper.getMainLooper() == Looper.myLooper());

        super.onAdClosed();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.ResultCode.NativeExpressAdClosed,
            "Ads view closed!");

        _adapter.logD("NativeExpressAdListener: onAdClosed end.");
    }

    @Override
    public void onAdFailedToLoad(int errorCode) {
        _adapter.logD("NativeExpressAdListener: onAdFailedToLoad begin.");
        assert (Looper.getMainLooper() == Looper.myLooper());

        _adapter.logE("NativeExpressAdListener: onAdFailedToLoad errorCode = " + errorCode);

        super.onAdFailedToLoad(errorCode);

        String errorDescription = "Unknown error";
        switch (errorCode) {
            case AdRequest.ERROR_CODE_NETWORK_ERROR:
                errorDescription = "Network error";
                break;
            case AdRequest.ERROR_CODE_INVALID_REQUEST:
                errorDescription = "The ad request is invalid";
                break;
            case AdRequest.ERROR_CODE_NO_FILL:
                errorDescription = "The ad request is successful, but no ad was returned due to lack of ad inventory.";
                break;
            default:
                break;
        }
        _adapter.logE("NativeExpressAdListener: onAdFailedToLoad errorDescription = " + errorDescription);
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.ResultCode.NativeExpressAdFailedToLoad,
            errorDescription);

        _adapter.logD("NativeExpressAdListener: onAdFailedToLoad end.");
    }

    @Override
    public void onAdLeftApplication() {
        _adapter.logD("NativeExpressAdListener: onAdLeftApplication: begin.");
        assert (Looper.getMainLooper() == Looper.myLooper());

        super.onAdLeftApplication();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.ResultCode.NativeExpressAdLeftApplication,
            "Ads left application!");

        _adapter.logD("NativeExpressAdListener: onAdLeftApplication: end.");
    }

    @Override
    public void onAdOpened() {
        _adapter.logD("NativeExpressAdListener: onAdOpened: begin.");
        assert (Looper.getMainLooper() == Looper.myLooper());

        super.onAdOpened();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.ResultCode.NativeExpressAdOpened,
            "Ads view shown!");

        _adapter.logD("NativeExpressAdListener: onAdOpened: end.");
    }

    @Override
    public void onAdLoaded() {
        _adapter.logD("NativeExpressAdListener: onAdLoaded: begin.");
        assert (Looper.getMainLooper() == Looper.myLooper());

        super.onAdLoaded();
        AdsWrapper.onAdsResult(_adapter, AdsWrapper.ResultCode.NativeExpressAdLoaded,
            "Ads request received success!");

        if (_nativeExpressAdView.get() != null) {
            _nativeExpressAdView.get().setVisibility(View.GONE);
            _nativeExpressAdView.get().setVisibility(View.VISIBLE);
        }

        _adapter.logD("NativeExpressAdListener: onAdLoaded: end.");
    }
}
