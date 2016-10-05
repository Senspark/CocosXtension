package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;

import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesActivityResultCodes;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.games.achievement.Achievements.UpdateAchievementResult;
import com.google.android.gms.games.leaderboard.Leaderboards.SubmitScoreResult;
import com.google.games.utils.GameHelper;

import java.util.Hashtable;
import java.util.concurrent.TimeUnit;

public class SocialGooglePlay implements InterfaceSocial, PluginListener {
	public final static String LOG_TAG = "SocialGooglePlay";
	
	protected Context mContext;
	protected GameHelper mGameHelper;
	protected boolean mDebug = false;
	protected SocialGooglePlay mAdapter;
	
	public static final int REQUEST_CODE_LEADERBOARD = 0x1001;
	public static final int REQUEST_CODE_ACHIEVEMENT = 0x1002;
	
	protected int mCurrentCallbackID = 0;

	public SocialGooglePlay(Context context) {
		mContext = context;
		PluginWrapper.addListener(this);
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
	public void submitScore(String leaderboard_id, int submitscore, final int callbackID) {
		final String leaderboardID = leaderboard_id;
		final long score = submitscore;
		logD("Submit score " + score + " to leaderboard " + leaderboardID);
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			
			@Override
			protected Integer doInBackground(Void... params) {
				if (mGameHelper.getApiClient() != null && mGameHelper.getApiClient().isConnected()) {  			//Fabric #2: Adding apiClient check block
					SubmitScoreResult mResult = Games.Leaderboards.submitScoreImmediate(mGameHelper.getApiClient(), leaderboardID, score).await(30, TimeUnit.SECONDS);
					return mResult.getStatus().getStatusCode();
				} else {
					Log.e(LOG_TAG, "mGameHelper.getApiClient NULL");
					return GamesStatusCodes.STATUS_INTERNAL_ERROR;
				}
			}

			@Override
			protected void onPostExecute(Integer result) {
				super.onPostExecute(result);
				if (result == GamesStatusCodes.STATUS_OK) {
					logD("Submit score successfully.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_SUBMITSCORE_SUCCESS, "Submitted score " + score, callbackID);
				} else {
					logD("Submit score failed.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_SUBMITSCORE_FAILED, "Submitted score " + score + " failed.", callbackID);
				}
			}
		};
		
		task.execute();
	}

	public void showLeaderboards(int callbackID) {
		mCurrentCallbackID = callbackID;
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				((Activity) mContext).startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mGameHelper.getApiClient()), REQUEST_CODE_LEADERBOARD);
			}
		});
	}
	
	@Override
	public void showLeaderboard(final String leaderboardID, int callbackID) {
		mCurrentCallbackID = callbackID;
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				((Activity) mContext).startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mGameHelper.getApiClient()), REQUEST_CODE_LEADERBOARD);
			}
		});
	}

	@Override
	public void unlockAchievement(Hashtable<String, String> achInfo, final int callbackID) {
		final String achievementId = achInfo.get("achievementId");
		final int percentComplete = Integer.parseInt(achInfo.get("percent").trim());

		if (percentComplete >= 100) {

			AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
				@Override
				protected Integer doInBackground(Void... params) {
					if (mGameHelper.getApiClient() != null && mGameHelper.getApiClient().isConnected()) {
						UpdateAchievementResult result = Games.Achievements.unlockImmediate(mGameHelper.getApiClient(), achievementId).await(30, TimeUnit.SECONDS);
						return result.getStatus().getStatusCode();
					} else {
						Log.e(LOG_TAG, "mGameHelper.getApiClient NULL");
						return GamesStatusCodes.STATUS_INTERNAL_ERROR;
					}
				}

				@Override
				protected void onPostExecute(Integer result) {
					if (result == GamesStatusCodes.STATUS_OK) {
						logD("Unlock achievement with id " + achievementId + " successfully.");
						SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_SUCCESS, "Unlock achievement with id " + achievementId + " successfully.", callbackID);
					} else {
						logD("Unlock achievement with id " + achievementId + " failed.");
						SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_FAILED, "Unlock achievement with id " + achievementId + " failed.", callbackID);
					}
				}
			};
			task.execute();

		} else {
			AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
				@Override
				protected Integer doInBackground(Void... params) {
					UpdateAchievementResult result = Games.Achievements.incrementImmediate(mGameHelper.getApiClient(), achievementId, percentComplete).await(30, TimeUnit.SECONDS);
					return result.getStatus().getStatusCode();
				}

				@Override
				protected void onPostExecute(Integer result) {
					if (result == GamesStatusCodes.STATUS_OK) {
						Log.i(LOG_TAG, "Increment achievement with id " + achievementId + " successfully with percentage: " + percentComplete);
						SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_SUCCESS, "Increment achievement with id " + achievementId + " successfully with percentage: " + percentComplete, callbackID);
					} else {
						Log.i(LOG_TAG, "Increment achievement with id " + achievementId + " failed.");
						SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_UNLOCKACH_FAILED, "Increment achievement with id " + achievementId + " failed.", callbackID);
					}
				}
			};
			task.execute();
		}
	}

	public void revealAchievement(Hashtable<String, String> achInfo, final int callbackID) {
		final String achievementId = achInfo.get("achievementId");
		
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			@Override
			protected Integer doInBackground(Void... params) {
				UpdateAchievementResult result = Games.Achievements.revealImmediate(mGameHelper.getApiClient(), achievementId).await(30, TimeUnit.SECONDS);
				return result.getStatus().getStatusCode();
			}

			@Override
			protected void onPostExecute(Integer result) {
				if (result == GamesStatusCodes.STATUS_OK) {
					logD("Unlock achievement with id " + achievementId + " successfully.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_REVEALACH_SUCCESS, "Unlock achievement with id " + achievementId + " successfully.", callbackID);
				} else {
					logD("Unlock achievement with id " + achievementId + " failed.");
					SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_REVEALACH_FAILED, "Unlock achievement with id " + achievementId + " failed.", callbackID);
				}
			}
		};
		
		task.execute();
	}

	public void resetAchievement(final String achievementID, final int callbackID) {
		logD("Comming soon.");
		SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_RESETACH_FAILED, "Comming soon.", 0);
	}

	public void resetAchievements(int callbackID) {
		logD("Comming soon.");
		SocialWrapper.onSocialResult(mAdapter, SocialWrapper.SOCIAL_RESETACH_FAILED, "Comming soon.", 0);
	}
	
	@Override
	public void showAchievements(int callbackID) {
		mCurrentCallbackID = callbackID;
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

	@Override
	public void onStart() {

	}

	@Override
	public void onResume() {

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
		Log.i(LOG_TAG, "RequestCode: " + requestCode);
		Log.i(LOG_TAG, "Result Code: " + resultCode);

		if (requestCode != REQUEST_CODE_ACHIEVEMENT && requestCode != REQUEST_CODE_LEADERBOARD) {
			Log.i(LOG_TAG, "SoicalGooglePlay: request code not meant for us. Ignoring");
			return false;
		}

		if (requestCode == REQUEST_CODE_ACHIEVEMENT) {
			SocialWrapper.onDialogDissmissedWithCallback(mCurrentCallbackID);
			mCurrentCallbackID = 0;
		}

		if (requestCode == REQUEST_CODE_LEADERBOARD) {
			SocialWrapper.onDialogDissmissedWithCallback(mCurrentCallbackID);
			mCurrentCallbackID = 0;
		}

		if ((requestCode == REQUEST_CODE_ACHIEVEMENT || requestCode == REQUEST_CODE_LEADERBOARD) && resultCode == GamesActivityResultCodes.RESULT_RECONNECT_REQUIRED) {
			Log.i(LOG_TAG, "It looks like that user has logged out from GooglePlay's UI. So disconnect GameHelper also to avoid crashing.");
			mGameHelper.disconnect();
		}

		return true;
	}
}
