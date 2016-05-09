package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.util.Log;

import com.jirbo.adcolony.AdColony;
import com.jirbo.adcolony.AdColonyAd;
import com.jirbo.adcolony.AdColonyAdAvailabilityListener;
import com.jirbo.adcolony.AdColonyAdListener;
import com.jirbo.adcolony.AdColonyV4VCAd;
import com.jirbo.adcolony.AdColonyV4VCListener;
import com.jirbo.adcolony.AdColonyV4VCReward;
import com.jirbo.adcolony.AdColonyVideoAd;

import java.util.Hashtable;

public class AdsColony implements InterfaceAds, PluginListener, AdColonyAdAvailabilityListener, AdColonyV4VCListener, AdColonyAdListener {
	public static final String LOG_TAG = "AdsColony";

	protected Context mContext = null;
	protected boolean isDebug = false;
	protected String mClientOptions = null;
	protected static AdsColony mAdapter = null;
	
	public AdsColony(Context context) {
		this.mContext = context;
		mAdapter = this;
        PluginWrapper.addListener(this);
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		String appId = devInfo.get("AdColonyAppID");
		String zoneIds = devInfo.get("AdColonyZoneIDs");

		try {
			PackageInfo pInfo = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
			String versionName = pInfo.versionName;
			mClientOptions = String.format("version:" + versionName + ",store:google");

			Log.i(LOG_TAG, "### AdColony client option: " + mClientOptions);
		} catch (PackageManager.NameNotFoundException e) {
			e.printStackTrace();
		}
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
					AdColony.addAdAvailabilityListener(mAdapter);
					AdColony.addV4VCListener(mAdapter);
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
		ad.withListener(mAdapter);
		ad.show();
	}
	
	public void cacheInterstitial(final String zoneID) {
		Log.e(LOG_TAG, "AdColony does not support cacheInterstitial method");
	}
	
	public boolean hasRewardedVideo(final String zoneID) {
		return AdColony.statusForZone(zoneID).equals("active");
	}
	
	public void showRewardedVideo(Hashtable<String, String> adsInfo) {
		String zoneID = adsInfo.get("Param1");
		boolean isShowPrePopup = Boolean.parseBoolean(adsInfo.get("Param2"));
		boolean isShowPostPopup = Boolean.parseBoolean(adsInfo.get("Param3"));

		Log.i(LOG_TAG, "zoneID: " + zoneID);
		Log.i(LOG_TAG, "isShowPre: " + isShowPrePopup);
		Log.i(LOG_TAG, "isShowPost: " + isShowPostPopup);

		AdColonyV4VCAd ad = new AdColonyV4VCAd(zoneID);
		ad.withListener(mAdapter);
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
		return true;
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

	@Override
	public void onAdColonyAdAttemptFinished(AdColonyAd ad) {
		if (ad.shown()) {
			AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_AdsShown, "AdColony Interstitial Ad shown");
		} else if (ad.notShown()) {
			AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "AdColony ad not show with error UNKNOWN");
		} else if (ad.skipped()) {
			AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "AdColony ad DISMISS");		
		}
	}

	@Override
	public void onAdColonyAdStarted(AdColonyAd ad) {
		AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_VideoShown, "AdColony started showing");
	}

	@Override
	public void onAdColonyV4VCReward(AdColonyV4VCReward ad) {
		if (ad.success()) {
			AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_VideoCompleted, "AdColony V4VC succeeded");
		} else {
			AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_VideoDismissed, "AdColony V4VC dismissed");
		}
	}

	@Override
	public void onAdColonyAdAvailabilityChange(boolean ad, String arg1) {
		AdsWrapper.onAdsResult(AdsColony.mAdapter, AdsWrapper.RESULT_CODE_VideoReceived, "AdColony video received");
	}
}
