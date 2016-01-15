package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.jirbo.adcolony.AdColony;
import com.jirbo.adcolony.AdColonyV4VCAd;
import com.jirbo.adcolony.AdColonyVideoAd;

public class AdsAdColony implements InterfaceAds, PluginListener {
	public static final String LOG_TAG = "AdsAdColony";

	protected Context mContext = null;
	protected boolean isDebug = false;
	protected String mClientOptions = null;
	protected AdColonyListener mListener = null;
	protected static AdsAdColony mAdapter = null;
	
	public AdsAdColony(Context context) {
		this.mContext = context;
		this.mListener = new AdColonyListener();
		mAdapter = this;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		String appId = devInfo.get("AdColonyAppID");
		String zoneIds = devInfo.get("AdColonyZoneIDs");
		configure(appId, zoneIds);
	}

	public void configure(final String appId, final String zoneIds) {
		try {
			final Activity activity = (Activity) mContext;
			activity.runOnUiThread(new Runnable() {
				@Override
				public void run() {
					AdColony.configure(activity, mClientOptions, appId,
							zoneIds.split(","));
					AdColony.addAdAvailabilityListener(mListener);
					AdColony.addV4VCListener(mListener);
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
			Log.i(LOG_TAG, "Error when configuring AdColony");
		}
	}

	public boolean hasInterstitial(final String zoneID) {
		return AdColony.statusForZone(zoneID).equals("active");
	}
	
	public void showInterstitial(final String zoneID) {
		AdColonyVideoAd ad = new AdColonyVideoAd(zoneID);
		ad.withListener(mListener);
		ad.show();
	}
	
	public void cacheInterstitial(final String zoneID) {
		Log.e(LOG_TAG, "AdColony does not support cacheInterstitial method");
	}
	
	public boolean hasRewardedVideo(final String zoneID) {
		return AdColony.statusForZone(zoneID).equals("active");
	}
	
	public void showRewardedVideo(final String zoneID, boolean isShowPrePopup, boolean isShowPostPopup) {
		AdColonyV4VCAd ad = new AdColonyV4VCAd(zoneID);
		ad.withListener(mListener);
		ad.withConfirmationDialog(isShowPrePopup);
		ad.withResultsDialog(isShowPostPopup);
		ad.show();
	}
	
	public void cacheRewardedVideo(final String zoneID) {
		Log.e(LOG_TAG, "AdColony does not support cacheRewardedVideo method");
	}
	
	@Override
	public void showAds(Hashtable<String, String> adsInfo, int pos) {
		Log.e(LOG_TAG, "AdColony does not support showAds method.");
	}

	@Override
	public void hideAds(Hashtable<String, String> adsInfo) {
		Log.i(LOG_TAG, "AdColony does not support hide ads.");
	}

	@Override
	public void queryPoints() {
		Log.i(LOG_TAG, "AdColony does not support query points.");
	}

	@Override
	public void spendPoints(int points) {
		Log.i(LOG_TAG, "AdColony does not support spend points.");
	}

	@Override
	public void setDebugMode(boolean debug) {
		isDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "2.2.1";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

	@Override
	public void onResume() {
		AdColony.resume((Activity) mContext);
	}

	@Override
	public void onPause() {
		AdColony.pause();
	}

	@Override
	public void onDestroy() {
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		return false;
	}

	@Override
	public void onStart() {
		
	}

	@Override
	public void onStop() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onBackPressed() {
		AdColony.onBackPressed();		
	}

}
