package org.cocos2dx.plugin;

import android.support.annotation.NonNull;

import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

import java.lang.ref.WeakReference;

/**
 * Created by nikelarteta on 4/11/16.
 */
public class RewardedAdListener implements RewardedVideoAdListener {
    private AdsAdmob _adapter;
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
    public void onRewarded(RewardItem reward) {
        _adapter.logD("RewardedAdListener: onRewarded.");
    }

    @Override
    public void onRewardedVideoAdLeftApplication() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLeftApplication begin.");

        refreshAdAvailability();

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLeftApplication end.");
    }

    @Override
    public void onRewardedVideoAdClosed() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdClosed begin.");

        refreshAdAvailability();

        AdsWrapper.onAdsResult(_adapter,
            AdsWrapper.RESULT_CODE_VideoClosed, "Reward based video ad is closed.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdClosed end.");
    }

    @Override
    public void onRewardedVideoAdFailedToLoad(int errorCode) {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdFailedToLoad: begin errorCode = " + errorCode);

        refreshAdAvailability();

        AdsWrapper.onAdsResult(_adapter,
            AdsWrapper.RESULT_CODE_VideoUnknownError,
            "Rewarded based video ad is failed to receive/load with error: " + errorCode);

        _adapter.logE("RewardedAdListener: onRewardedVideoAdFailedToLoad: end.");
    }

    @Override
    public void onRewardedVideoAdLoaded() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: begin.");

        refreshAdAvailability();

        AdsWrapper.onAdsResult(_adapter,
            AdsWrapper.RESULT_CODE_VideoReceived,
            "Reward based video ad is received/loaded.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoAdOpened() {
        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: begin.");

        refreshAdAvailability();

        AdsWrapper.onAdsResult(_adapter,
            AdsWrapper.RESULT_CODE_VideoShown,
            "Opened reward based video ad.");

        _adapter.logD("RewardedAdListener: onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoStarted() {
        _adapter.logD("RewardedAdListener: onRewardedVideoStarted.");

        refreshAdAvailability();
    }
}
