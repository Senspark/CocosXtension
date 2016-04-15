package org.cocos2dx.plugin;

import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

/**
 * Created by nikelarteta on 4/11/16.
 */
public class RewardedAdListener implements RewardedVideoAdListener {

    @Override
    public void onRewarded(RewardItem reward) {

    }

    @Override
    public void onRewardedVideoAdLeftApplication() {

    }

    @Override
    public void onRewardedVideoAdClosed() {
        AdsAdmob.mAdapter.logD("Reward based video ad is closed.");
        AdsWrapper.onAdsResult(AdsAdmob.mAdapter, AdsWrapper.RESULT_CODE_VideoClosed, "Reward based video ad is closed.");
    }

    @Override
    public void onRewardedVideoAdFailedToLoad(int errorCode) {
        AdsAdmob.mAdapter.logD("Reward based video ad is failed to receive/load with error: " + errorCode);
        synchronized (AdsAdmob.mAdapter.mLock) {
            AdsAdmob.mAdapter.mIsRewardedVideoLoading = false;
        }
        AdsWrapper.onAdsResult(AdsAdmob.mAdapter, AdsWrapper.RESULT_CODE_VideoUnknownError, "Rewarded based video ad is failed to receive/load with error: " + errorCode);
    }

    @Override
    public void onRewardedVideoAdLoaded() {
        AdsAdmob.mAdapter.logD("Reward based video ad is received/loaded.");
        synchronized (AdsAdmob.mAdapter.mLock) {
            AdsAdmob.mAdapter.mIsRewardedVideoLoading = false;
        }
        AdsWrapper.onAdsResult(AdsAdmob.mAdapter, AdsWrapper.RESULT_CODE_VideoReceived, "Reward based video ad is received/loaded.");
    }

    @Override
    public void onRewardedVideoAdOpened() {
        AdsAdmob.mAdapter.logD("Opened reward based video ad.");
        AdsWrapper.onAdsResult(AdsAdmob.mAdapter, AdsWrapper.RESULT_CODE_VideoShown, "Opened reward based video ad.");
    }

    @Override
    public void onRewardedVideoStarted() {
        AdsAdmob.mAdapter.logD("Reward based video ad started playing.");
    }
}
