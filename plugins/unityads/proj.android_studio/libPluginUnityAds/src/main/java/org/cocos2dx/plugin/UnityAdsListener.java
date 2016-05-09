package org.cocos2dx.plugin;

import com.unity3d.ads.android.IUnityAdsListener;

public class UnityAdsListener implements IUnityAdsListener {

	@Override
	public void onFetchCompleted() {
		AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_VideoReceived, "UnityAds: Ads did receive");
	}

	@Override
	public void onFetchFailed() {
		AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "UnityAds: Ads did fail to receive");
	}

	@Override
	public void onHide() {
		AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_VideoClosed, "UnityAds: Ads did hide");
	}

	@Override
	public void onShow() {
		AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_VideoShown, "UnityAds: Ads did show");
	}

	@Override
	public void onVideoCompleted(String itemKey, boolean skipped) {
		if (skipped) {
			AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_VideoDismissed, "UnityAds: Video dismiss/skipped");
		} else {
			AdsWrapper.onAdsResult(AdsUnity.mAdapter, AdsWrapper.RESULT_CODE_VideoCompleted, "UnityAds: Video completed successfully");
		}
		
	}

	@Override
	public void onVideoStarted() {
		// TODO Auto-generated method stub
		
	}

}
