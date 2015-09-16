package org.cocos2dx.plugin;

import java.util.Hashtable;
import java.util.concurrent.TimeUnit;

import android.app.Activity;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.games.achievement.Achievements.UpdateAchievementResult;
import com.google.android.gms.games.leaderboard.Leaderboards.SubmitScoreResult;
import com.google.games.utils.GameHelper;

public class SocialGooglePlay implements InterfaceSocial {
	public final static String LOG_TAG = "SocialGooglePlay";
	
	protected Context mContext;
	protected GameHelper mGameHelper;
	protected boolean mDebug = false;
	protected SocialGooglePlay mAdapter;
	
	public static final int REQUEST_CODE_LEADERBOARD = 0x1001;
	public static final int REQUEST_CODE_ACHIEVEMENT = 0x1001;
	
	
	public SocialGooglePlay(Context context) {
		mContext = context;
		mAdapter = this;
		mGameHelper = GooglePlayAgent.getInstance().getGameHelper();
		
		if (mGameHelper == null) {
			logD("Please call GoogleAgent setup method first.");
		}
	}
	
	protected void logD(String message) {
		if (mDebug) {
			Log.d(LOG_TAG, message);
		}
	}
	
	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
	}

	@Override
	public void submitScore(String leaderboard_id, long submitscore) {
		final String leaderboardID = leaderboard_id;
		final long score = submitscore;
		logD("Submit score " + score + " to leaderboard " + leaderboardID);
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			
			@Override
			protected Integer doInBackground(Void... params) {
				SubmitScoreResult mResult = Games.Leaderboards.submitScoreImmediate(mGameHelper.getApiClient(), leaderboardID, score).await(30, TimeUnit.SECONDS);
				return mResult.getStatus().getStatusCode();
			};
			
			@Override
			protected void onPostExecute(Integer result) {
				super.onPostExecute(result);
				if (result == GamesStatusCodes.STATUS_OK) {
					logD("Submit score successfully.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_SUBMITSCORE_SUCCESS, "Submitted score " + score);
				} else {
					logD("Submit score failed.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_SUBMITSCORE_FAILED, "Submitted score " + score + " failed.");
				}
			}
		};
		
		task.execute();
	}

	public void showLeaderboards() {
		PluginWrapper.runOnMainThread(new Runnable() {
			
			@Override
			public void run() {
				((Activity) mContext).startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mGameHelper.getApiClient()), REQUEST_CODE_LEADERBOARD);
			}
		});
	}
	
	@Override
	public void showLeaderboard(final String leaderboardID) {
		PluginWrapper.runOnMainThread(new Runnable() {
			
			@Override
			public void run() {
				((Activity) mContext).startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mGameHelper.getApiClient()), REQUEST_CODE_LEADERBOARD);
			}
		});
	}

	@Override
	public void unlockAchievement(Hashtable<String, String> achInfo) {
		final String achievementId = achInfo.get("achievementId");
		
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			@Override
			protected Integer doInBackground(Void... params) {
				UpdateAchievementResult result = Games.Achievements.unlockImmediate(mGameHelper.getApiClient(), achievementId).await(30, TimeUnit.SECONDS);
				return result.getStatus().getStatusCode();
			}
			
			@Override
			protected void onPostExecute(Integer result) {
				if (result == GamesStatusCodes.STATUS_OK) {
					logD("Unlock achievement with id " + achievementId + " successfully.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_SUCCESS, "Unlock achievement with id " + achievementId + " successfully.");
				} else {
					logD("Unlock achievement with id " + achievementId + " failed.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_FAILED, "Unlock achievement with id " + achievementId + " failed.");
				}
			};
		};
		task.execute();
	}

	public void revealAchievement(Hashtable<String, String> achInfo) {
		final String achievementId = achInfo.get("achievementId");
		
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			@Override
			protected Integer doInBackground(Void... params) {
				UpdateAchievementResult result = Games.Achievements.revealImmediate(mGameHelper.getApiClient(), achievementId).await(30, TimeUnit.SECONDS);
				return result.getStatus().getStatusCode();
			};
			
			@Override
			protected void onPostExecute(Integer result) {
				if (result == GamesStatusCodes.STATUS_OK) {
					logD("Unlock achievement with id " + achievementId + " successfully.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_REVEALACH_SUCCESS, "Unlock achievement with id " + achievementId + " successfully.");
				} else {
					logD("Unlock achievement with id " + achievementId + " failed.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_REVEALACH_FAILED, "Unlock achievement with id " + achievementId + " failed.");
				}
			};
		};
		
		task.execute();
	}
	
	public void resetAchievements() {
		logD("Comming soon.");
		SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_RESETACH_FAILED, "Comming soon.");
	}
	
	@Override
	public void showAchievements() {
		PluginWrapper.runOnMainThread(new Runnable() {
			
			@Override
			public void run() {
				((Activity) mContext).startActivityForResult(Games.Achievements.getAchievementsIntent(mGameHelper.getApiClient()), REQUEST_CODE_ACHIEVEMENT);
			}
		});
	}

	@Override
	public void setDebugMode(boolean debug) {
		mDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "1.4.1";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

}
