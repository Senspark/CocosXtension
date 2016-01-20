package org.cocos2dx.plugin;

import java.util.Hashtable;

import com.chartboost.sdk.Chartboost;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class AdsChartboost implements InterfaceAds, PluginListener {
	protected static final String LOG_TAG = "Chartboost";
	
	protected Context mContext;
	protected ChartboostListener mListener;
	protected boolean mDebug = true;
	protected static AdsChartboost mAdapter = null;

	protected static final int CB_TYPE_INTERSTITIAL = 0;
	protected static final int CB_TYPE_REWARDED_VIDEO = 1;
	protected static final int CB_TYPE_MORE_APPS = 2;

	protected void logE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected void logD(String msg) {
		if (mDebug)
			Log.d(LOG_TAG, msg);
	}

	public AdsChartboost(Context context) {
		mContext = context;
		mAdapter = this;
		mListener = new ChartboostListener();
		logD("Register Chartboost");
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		final String appId = devInfo.get("ChartboostAppId");
		final String appSignature = devInfo.get("ChartboostAppSignature");
		
		final Activity activity = (Activity) mContext;
		activity.runOnUiThread(new Runnable() {
			
			@Override
			public void run() {
				Chartboost.startWithAppId(activity, appId, appSignature);
				Chartboost.setDelegate(mListener);
				Chartboost.setFramework(Chartboost.CBFramework.CBFrameworkCocos2dx);
				Chartboost.setImpressionsUseActivities(true);
				Chartboost.onCreate(activity);
				Chartboost.onStart(activity);
				Chartboost.setAutoCacheAds(true);
			}
		});
	}

	@Override
	public void showAds(Hashtable<String, String> adsInfo, int pos) {
		Log.e(LOG_TAG, "AdChartboost does not support showAds method. Use showInterstitial instead");
	}
	
	public boolean isAnyViewVisible() {
		return Chartboost.isAnyViewVisible();
	}
	
	public void setAutoCacheAds(boolean shouldCache) {
		Chartboost.setAutoCacheAds(shouldCache);
	}
	
	public boolean getAutoCacheAds() {
		return Chartboost.getAutoCacheAds();
	}
	
	public void closeImpression() {
		Chartboost.closeImpression();
	}
	
	public void disPassAgeGate(boolean pass) {
		Chartboost.didPassAgeGate(pass);
	}
	
	public boolean hasMoreApps(Hashtable<String, String> adsInfo) {
		return Chartboost.hasMoreApps(adsInfo.get("location"));
	}
	
	public void cacheMoreApps(Hashtable<String, String> adsInfo) {
		Chartboost.cacheMoreApps(adsInfo.get("location"));
	}
	
	public void showMoreApps(Hashtable<String, String> adsInfo) {
		Chartboost.showMoreApps(adsInfo.get("location"));
	}
	
	public boolean hasInterstitial(Hashtable<String, String> adsInfo) {
		return Chartboost.hasInterstitial(adsInfo.get("location"));
	}
	
	public void cacheInterstitial(Hashtable<String, String> adsInfo) {
		Chartboost.cacheInterstitial(adsInfo.get("location"));
	}
	
	public void showInterstitial(Hashtable<String, String> adsInfo) {
		Chartboost.showInterstitial(adsInfo.get("location"));
	}
	
	public boolean hasRewardedVideo(Hashtable<String, String> adsInfo) {
		return Chartboost.hasRewardedVideo(adsInfo.get("location"));
	}
	
	public void cacheRewardedVideo(Hashtable<String, String> adsInfo) {
		Chartboost.cacheRewardedVideo(adsInfo.get("location"));
	}
	
	public void showRewardedVideo(Hashtable<String, String> adsInfo) {
		Chartboost.showRewardedVideo(adsInfo.get("location"));
	}
	
	@Override
	public void hideAds(Hashtable<String, String> adsInfo) {
		logD("Chartboost not implement this method on Android.");
	}

	@Override
	public void queryPoints() {
		logD("Chartboost not implement this method on Android.");
	}

	@Override
	public void spendPoints(int points) {
		logD("Chartboost not implement this method on Android.");
	}

	@Override
	public void setDebugMode(boolean debug) {
		mDebug = debug;
	}

	@Override
	public void onResume() {
		Chartboost.onResume((Activity) mContext);
	}

	@Override
	public void onPause() {
		Chartboost.onPause((Activity) mContext);
	}

	@Override
	public void onDestroy() {
		Chartboost.onDestroy((Activity) mContext);
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		return false;
	}

	@Override
	public void onStart() {
		Chartboost.onStart((Activity) mContext);
	}

	@Override
	public void onStop() {
		Chartboost.onStop((Activity) mContext);
	}

	@Override
	public void onBackPressed() {
		if (Chartboost.onBackPressed()) {
			return;
		}
	}
	
	@Override
	public String getSDKVersion() {
		return "5.5.3";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

}
