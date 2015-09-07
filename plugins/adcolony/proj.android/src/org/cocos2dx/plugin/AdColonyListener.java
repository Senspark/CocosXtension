package org.cocos2dx.plugin;

import com.jirbo.adcolony.AdColonyAd;
import com.jirbo.adcolony.AdColonyAdAvailabilityListener;
import com.jirbo.adcolony.AdColonyAdListener;
import com.jirbo.adcolony.AdColonyV4VCListener;
import com.jirbo.adcolony.AdColonyV4VCReward;

public class AdColonyListener implements AdColonyAdAvailabilityListener, AdColonyV4VCListener, AdColonyAdListener {

	@Override
	public void onAdColonyAdAttemptFinished(AdColonyAd ad) {
	}

	@Override
	public void onAdColonyAdStarted(AdColonyAd ad) {
	}

	@Override
	public void onAdColonyV4VCReward(AdColonyV4VCReward ad) {
	}

	@Override
	public void onAdColonyAdAvailabilityChange(boolean ad, String arg1) {
	}
}
