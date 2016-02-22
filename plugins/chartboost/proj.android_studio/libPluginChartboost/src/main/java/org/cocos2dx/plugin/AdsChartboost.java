package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.chartboost.sdk.Chartboost;

import java.util.Arrays;
import java.util.Hashtable;
import java.util.List;

public class AdsChartboost implements InterfaceAds, PluginListener {
	protected static final String LOG_TAG = "Chartboost";
	
	protected Context mContext;
	protected ChartboostListener mListener;
	protected boolean mDebug = true;
	protected static AdsChartboost mAdapter = null;

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
        PluginWrapper.addListener(this);
		logD("Register Chartboost");
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		final Hashtable<String, String> _devInfo = devInfo;

		PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                String appId = _devInfo.get("ChartboostAppId");
                String appSignature = _devInfo.get("ChartboostAppSignature");
                Log.i(LOG_TAG, "Chartboost app id: " + appId);
                Log.i(LOG_TAG, "Chartboost app signature id: " + appSignature);
                Log.i(LOG_TAG, "Chartboost app activity: " + mContext);

                Chartboost.startWithAppId((Activity) mContext, appId, appSignature);
                Chartboost.setDelegate(mListener);
                Chartboost.setFramework(Chartboost.CBFramework.CBFrameworkCocos2dx);
                Chartboost.setImpressionsUseActivities(true);
                Chartboost.setAutoCacheAds(true);
                Chartboost.onCreate((Activity) mContext);
                Chartboost.onStart((Activity) mContext);
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

    public String getCBLocationFrom(String info) {
        List<String> cbStrLocations = Arrays.asList("Default", "Startup", "Home Screen", "Main Menu", "Game Screen", "Achievements", "Quests", "Pause", "Level Start", "Level Complete", "Turn Complete",
                "IAP Store", "GItem Store", "Game Over", "Leaderboard", "Settings", "Quit");

        List<String> cbLocations = Arrays.asList("CBLocationStartup", "CBLocationHomeScreen", "CBLocationMainMenu", "CBLocationGameScreen",
                "CBLocationAchievements", "CBLocationQuests", "CBLocationPause", "CBLocationLevelStart", "CBLocationLevelComplete",
                "CBLocationTurnComplete", "CBLocationIAPStore", "CBLocationItemStore", "CBLocationGameOver", "CBLocationLeaderBoard",
                "CBLocationSettings", "CBLocationQuit", "CBLocationDefault");

        for (int i = 0; i < cbStrLocations.size(); i++) {
            if (cbStrLocations.get(i) == info) {
                return cbStrLocations.get(i);
            }
        }

        return "Default";
    }

    public boolean hasMoreApps(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		return Chartboost.hasMoreApps(getCBLocationFrom(locationID));
	}

	
	public void cacheMoreApps(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		Chartboost.cacheMoreApps(getCBLocationFrom(locationID));
	}
	
	public void showMoreApps(String locationID) {
        final String location = locationID;
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
        Chartboost.showMoreApps(getCBLocationFrom(location));
	}
	
	public boolean hasInterstitial(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		return Chartboost.hasInterstitial(getCBLocationFrom(locationID));
	}
	
	public void cacheInterstitial(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		Chartboost.cacheInterstitial(getCBLocationFrom(locationID));
	}
	
	public void showInterstitial(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		Chartboost.showInterstitial(getCBLocationFrom(locationID));
	}
	
	public boolean hasRewardedVideo(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		return Chartboost.hasRewardedVideo(getCBLocationFrom(locationID));
	}
	
	public void cacheRewardedVideo(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		Chartboost.cacheRewardedVideo(getCBLocationFrom(locationID));
	}
	
	public void showRewardedVideo(String locationID) {
        Log.i(LOG_TAG, "Chartboost location: " + getCBLocationFrom(locationID));
		Chartboost.showRewardedVideo(getCBLocationFrom(locationID));
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
        Log.e(LOG_TAG, "Chartboost onResume");
		Chartboost.onResume((Activity) mContext);
	}

	@Override
	public void onPause() {
        Log.e(LOG_TAG, "Chartboost onPause");
		Chartboost.onPause((Activity) mContext);
	}

	@Override
	public void onDestroy() {
		Chartboost.onDestroy((Activity) mContext);
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		return true;
	}

	@Override
	public void onStart() {
        Log.e(LOG_TAG, "Chartboost onStart is triggered");
		Chartboost.onStart((Activity) mContext);
	}

	@Override
	public void onStop() {
        Log.e(LOG_TAG, "Chartboost onStop");
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
		return "6.2.0";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.1";
	}

}
