package org.cocos2dx.plugin;

import com.chartboost.sdk.ChartboostDelegate;

public class ChartboostListener extends ChartboostDelegate {
	@Override
	public void didCacheInterstitial(String location) {
		super.didCacheInterstitial(location);
	}

	@Override
	public void didCacheMoreApps(String location) {
		super.didCacheMoreApps(location);
	}

	@Override
	public void didCacheRewardedVideo(String location) {
		super.didCacheRewardedVideo(location);
	}

	public boolean shouldDisplayInterstitial(String location) {
		return false;
	}

	public boolean shouldDisplayMoreApps(String location) {
		return false;
	}

	public boolean shouldDisplayRewardedVideo(String location) {
		super.shouldDisplayRewardedVideo(location);
		return false;
	}

	public void didDisplayInterstitial(String location) {
		super.didDisplayInterstitial(location);
	}

	public void didDisplayMoreApps(String location) {
		super.didDisplayMoreApps(location);
	}

	public void didDisplayRewardedVideo(String location) {
		super.didDisplayRewardedVideo(location);
	}

	public void didDismissInterstitial(String location) {
	}

	public void didDismissMoreApps(String location) {
	}

	public void didDismissRewardedVideo(String location) {
	}

	public void didCloseInterstitial(String location) {
	}

	public void didCloseMoreApps(String location) {
	}

	public void didCloseRewardedVideo(String location) {
	}

	public void didClickInterstitial(String location) {
	}

	public void didClickMoreApps(String location) {
	}

	public void didClickRewardedVideo(String location) {
	}

	public void didCompleteRewardedVideo(String location, int reward) {
	}
}
