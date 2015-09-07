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

	public AdsAdColony(Context context) {
		this.mContext = context;
		this.mListener = new AdColonyListener();
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		String appId = devInfo.get("AdColonyAppId");
		String zoneIds = devInfo.get("AdColonyZoneIds");
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

	
	
	private void playVideoAd(String zoneId) {
		AdColonyVideoAd ad = new AdColonyVideoAd(zoneId);
		ad.withListener(mListener);
		ad.show();
	}

	private void playV4vc(String zone_id, boolean showPrePopup,
			boolean showPostPopup) {
		AdColonyV4VCAd ad = new AdColonyV4VCAd(zone_id);
		ad.withListener(this.mListener);
		ad.withConfirmationDialog(showPrePopup);
		ad.withResultsDialog(showPostPopup);
		ad.show();
	}

	@Override
	public void showAds(Hashtable<String, String> adsInfo, int pos) {
		final String zoneId = adsInfo.get("Param1");
		final boolean v4vc = Boolean.parseBoolean(adsInfo.get("Param2"));
		final boolean showPrePopup = Boolean.parseBoolean(adsInfo.get("Param3"));
		final boolean showPostPopup = Boolean.parseBoolean(adsInfo.get("Param4"));
		
		final Activity activity = (Activity) mContext;
		activity.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (v4vc) {
					playV4vc(zoneId, showPrePopup, showPostPopup);
				} else {
					playVideoAd(zoneId);
				}
			}
		});
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

}
