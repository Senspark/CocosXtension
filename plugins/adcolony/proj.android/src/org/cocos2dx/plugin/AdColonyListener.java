package org.cocos2dx.plugin;

import com.jirbo.adcolony.AdColonyAd;
import com.jirbo.adcolony.AdColonyAdAvailabilityListener;
import com.jirbo.adcolony.AdColonyAdListener;
import com.jirbo.adcolony.AdColonyV4VCListener;
import com.jirbo.adcolony.AdColonyV4VCReward;

public class AdColonyListener implements AdColonyAdAvailabilityListener, AdColonyV4VCListener, AdColonyAdListener {

	@Override
	public void onAdColonyAdAttemptFinished(AdColonyAd ad) {
		if (ad.shown()) {
			AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_AdsShown, "AdColony Interstitial Ad shown");
		} else if (ad.notShown()) {
			AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "AdColony ad not show with error UNKNOWN");
		} else if (ad.skipped()) {
			AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "AdColony ad DISMISS");		
		}
	}

	@Override
	public void onAdColonyAdStarted(AdColonyAd ad) {
		AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_VideoShown, "AdColony started showing");
	}

	@Override
	public void onAdColonyV4VCReward(AdColonyV4VCReward ad) {
		if (ad.success()) {
			AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_VideoCompleted, "AdColony V4VC succeeded");
		} else {
			AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_VideoDismissed, "AdColony V4VC dismissed");
		}
	}

	@Override
	public void onAdColonyAdAvailabilityChange(boolean ad, String arg1) {
		AdsWrapper.onAdsResult(AdsAdColony.mAdapter, AdsWrapper.RESULT_CODE_VideoReceived, "AdColony video received");
	}
}