package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.unity3d.ads.android.UnityAds;

import java.util.Hashtable;

public class AdsUnity implements InterfaceAds, PluginListener {
	public static final String LOG_TAG = "AdsUnityAd";

	protected Context mContext = null;
	protected boolean isDebug = false;
	protected String mClientOptions = null;
	protected UnityAdsListener mListener = null;
	protected static AdsUnity mAdapter = null;
	
	public AdsUnity(Context context) {
		this.mContext = context;
		this.mListener = new UnityAdsListener();
		mAdapter = this;
	}
	
	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		Log.i(LOG_TAG, "### Initializing UnityAds with id: " + devInfo.get("UnityAdsAppID"));
		UnityAds.init((Activity) mContext, devInfo.get("UnityAdsAppID"), mListener);
		UnityAds.setDebugMode(true);
		UnityAds.setListener(mListener);
	}

	public boolean hasInterstitial(final String zone) {
		Log.i(LOG_TAG, "has interstitial in zone " + zone + UnityAds.canShow());
		return UnityAds.canShow();
	}

	public boolean hasRewardedVideo(final String zone) {
		Log.i(LOG_TAG, "has rewarded in zone " + zone + UnityAds.canShow());
		return UnityAds.canShow();
	}

	public void showRewardedVideo(final String zone) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (hasRewardedVideo(zone)) {
					UnityAds.setZone(zone);
					UnityAds.show();
				} else {
					AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "UnityAds: Ad cannot show");
				}
			}
		});
	}
	
	public void showInterstitial(final String zone) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (hasInterstitial(zone)) {
					UnityAds.setZone(zone);
					UnityAds.show();
				} else {
					AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_UnknownError, "UnityAds: Ad cannot show");
				}
			}
		});
	}
	
	public void cacheInterstitial() {
		Log.e(LOG_TAG, "AdsUnity does not support cacheInterstitial");
	}
	
	@Override
	public void onStart() {
		
	}

	@Override
	public void onResume() {
		UnityAds.changeActivity((Activity) mContext);
		UnityAds.setListener(mListener);
	}

	@Override
	public void onPause() {
		
	}

	@Override
	public void onStop() {
		
	}

	@Override
	public void onDestroy() {
		
	}

	@Override
	public void onBackPressed() {
		
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		return false;
	}


	@Override
	public void showAds(Hashtable<String, String> adsInfo, int pos) {
		Log.e(LOG_TAG, "AdsUnity does not support showAds. Use showInterstitial instead");
	}

	@Override
	public void hideAds(Hashtable<String, String> adsInfo) {
		Log.e(LOG_TAG, "AdsUnity does not support hideAds.");
	}

	@Override
	public void queryPoints() {
		Log.e(LOG_TAG, "AdsUnity does not support queryPoints");
	}

	@Override
	public void spendPoints(int points) {
		Log.e(LOG_TAG, "AdsUnity does not support spendPoints");
	}

	@Override
	public void setDebugMode(boolean debug) {
		UnityAds.setDebugMode(debug);
	}

	@Override
	public String getSDKVersion() {
		return UnityAds.getSDKVersion();
	}

	@Override
	public String getPluginVersion() {
		return null;
	}
}
