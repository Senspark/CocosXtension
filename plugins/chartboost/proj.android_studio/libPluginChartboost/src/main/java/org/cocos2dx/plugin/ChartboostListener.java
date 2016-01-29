package org.cocos2dx.plugin;

import android.util.Log;

import com.chartboost.sdk.ChartboostDelegate;

public class ChartboostListener extends ChartboostDelegate {
	@Override
	public void didCacheInterstitial(String location) {
		super.didCacheInterstitial(location);
		Log.i("CHARTBOOST", "CHARTBOOST INTERSTITIAL did cached at location: " + location);
	}

	@Override
	public void didCacheMoreApps(String location) {
		super.didCacheMoreApps(location);
		Log.i("CHARTBOOST", "CHARTBOOST MORE APPS did cached at location: " + location);
	}

	@Override
	public void didCacheRewardedVideo(String location) {
		super.didCacheRewardedVideo(location);
	}

	@Override
	public boolean shouldDisplayInterstitial(String location) {
		return super.shouldDisplayInterstitial(location);
	}

	@Override
	public boolean shouldDisplayMoreApps(String location) {
		return super.shouldDisplayMoreApps(location);
	}

	@Override
	public boolean shouldDisplayRewardedVideo(String location) {
		return super.shouldDisplayRewardedVideo(location);
	}

	@Override
	public void didDisplayInterstitial(String location) {
		super.didDisplayInterstitial(location);
	}

	@Override
	public void didDisplayMoreApps(String location) {
		super.didDisplayMoreApps(location);
	}

	@Override
	public void didDisplayRewardedVideo(String location) {
		super.didDisplayRewardedVideo(location);
	}

	@Override
	public void didDismissInterstitial(String location) {
		AdsWrapper.onAdsResult(AdsChartboost.mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "AdChartboost interstitial dismissed");
	}

	@Override
	public void didDismissMoreApps(String location) {
		super.didDismissMoreApps(location);
		AdsWrapper.onAdsResult(AdsChartboost.mAdapter, AdsWrapper.RESULT_CODE_MoreAppsDismissed, "AdChartboost more apps dismissed");
	}

	@Override
	public void didDismissRewardedVideo(String location) {
		super.didDismissRewardedVideo(location);
	}

	@Override
	public void didCloseInterstitial(String location) {
		super.didCloseInterstitial(location);
	}

	@Override
	public void didCloseMoreApps(String location) {
		super.didCloseMoreApps(location);
	}

	@Override
	public void didCloseRewardedVideo(String location) {
		super.didCloseRewardedVideo(location);
	}

	@Override
	public void didClickInterstitial(String location) {
		super.didClickInterstitial(location);
	}

	@Override
	public void didClickMoreApps(String location) {
		super.didClickMoreApps(location);
	}

	@Override
	public void didClickRewardedVideo(String location) {
		super.didClickRewardedVideo(location);
	}

	@Override
	public void didCompleteRewardedVideo(String location, int reward) {
		super.didCompleteRewardedVideo(location, reward);
	}
}
