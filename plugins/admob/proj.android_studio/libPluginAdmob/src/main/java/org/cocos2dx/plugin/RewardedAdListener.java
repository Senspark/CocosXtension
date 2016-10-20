package org.cocos2dx.plugin;

import android.support.annotation.NonNull;
import android.util.Log;

import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

import org.cocos2dx.plugin.AdsWrapper.ResultCode;

/**
 * Created by nikelarteta on 4/11/16.
 */
class RewardedAdListener implements RewardedVideoAdListener {
    private static final String _Tag = RewardedAdListener.class.getName();

    private NativeCallback _callback;

    RewardedAdListener(@NonNull NativeCallback callback) {
        _callback = callback;
    }

    private void logD(String message) {
        Log.d(_Tag, message);
    }

    private void logE(String message) {
        Log.e(_Tag, message);
    }

    @Override
    public void onRewardedVideoAdLoaded() {
        logD("onRewardedVideoAdLoaded: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdLoaded, "Rewarded video ad loaded.");
        logD("onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoAdFailedToLoad(int errorCode) {
        logE("onRewardedVideoAdFailedToLoad: begin errorCode = " + errorCode);
        _callback.onEvent(ResultCode.RewardedVideoAdFailedToLoad, String.valueOf(errorCode));
        logE("onRewardedVideoAdFailedToLoad: end.");
    }

    @Override
    public void onRewardedVideoAdOpened() {
        logD("onRewardedVideoAdLoaded: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdOpened, "Rewarded video ad opened.");
        logD("onRewardedVideoAdLoaded: end.");
    }

    @Override
    public void onRewardedVideoStarted() {
        logD("onRewardedVideoStarted: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdStarted, "Rewarded video ad started");
        logD("onRewardedVideoStarted: end.");
    }

    @Override
    public void onRewardedVideoAdClosed() {
        logD("onRewardedVideoAdClosed: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdClosed, "Rewarded video ad closed.");
        logD("onRewardedVideoAdClosed: end.");
    }

    @Override
    public void onRewarded(RewardItem reward) {
        logD("onRewarded: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdRewarded,
            "Reward received with currency " + reward.getType() + ", amount " + reward.getAmount());
        logD("onRewarded: end.");
    }

    @Override
    public void onRewardedVideoAdLeftApplication() {
        logD("onRewardedVideoAdLeftApplication: begin.");
        _callback.onEvent(ResultCode.RewardedVideoAdLeftApplication,
            "Rewarded video ad left application");
        logD("RewardedAdListener: onRewardedVideoAdLeftApplication: end.");
    }
}
