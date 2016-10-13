package org.cocos2dx.plugin;

import android.support.annotation.NonNull;

import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

import java.lang.ref.WeakReference;

/**
 * Created by nikelarteta on 4/11/16.
 */
class RewardedAdListener implements RewardedVideoAdListener {
    private AdsAdmob                       _adapter;
    private WeakReference<RewardedVideoAd> _rewardedVideoAd;

    RewardedAdListener(@NonNull AdsAdmob adapter, RewardedVideoAd ad) {
        _adapter = adapter;
        _rewardedVideoAd = new WeakReference<>(ad);
    }

    private void refreshAdAvailability() {
        assert (_rewardedVideoAd.get() != null);

        if (_rewardedVideoAd.get() != null) {
            _adapter._changeRewardedAdAvailability(_rewardedVideoAd.get().isLoaded());
        }
    }

    @Override
    public void onRewardedVideoAdLoaded() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdLoaded, "Rewarded video ad loaded.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoAdFailedToLoad(int errorCode) {
        _adapter.logE(
            "RewardedAdListener: onRewardedVideoAdFailedToLoad: begin errorCode = " + errorCode);

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdFailedToLoad,
            String.valueOf(errorCode));

        _adapter.logE("RewardedAdListener: onRewardedVideoAdFailedToLoad: end.");
    }

    @Override
    public void onRewardedVideoAdOpened() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdOpened, "Rewarded video ad opened.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoStarted() {
        _adapter.logD("RewardedAdListener: onRewardedVideoStarted: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdStarted, "Rewarded video ad started");

        _adapter.logD("RewardedAdListener: onRewardedVideoStarted: end.");
    }

    @Override
    public void onRewardedVideoAdClosed() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdClosed: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdClosed, "Rewarded video ad closed.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdClosed: end.");
    }

    @Override
    public void onRewarded(RewardItem reward) {
        _adapter.logD("RewardedAdListener: onRewarded: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdRewarded,
            "Reward received with currency " + reward.getType() + ", amount " + reward.getAmount());

        _adapter.logD("RewardedAdListener: onRewarded: end.");
    }

    @Override
    public void onRewardedVideoAdLeftApplication() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLeftApplication: begin.");

        refreshAdAvailability();
        AdsWrapper.onAdsResult(_adapter, ResultCode.RewardedVideoAdLeftApplication,
            "Rewarded video ad left application");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLeftApplication: end.");
    }
}
