package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.games.Games;
import com.google.games.utils.GameHelper;
import com.google.games.utils.GameHelper.GameHelperListener;

import java.util.Hashtable;

public class UserGooglePlay implements InterfaceUser, PluginListener {
	protected static final String LOG_TAG = "UserGooglePlay";
	
	protected Context mContext;
	protected UserGooglePlay mAdapter;
	protected GameHelper mGameHelper;
	protected GameHelperListener mGameHelperListener;
	protected boolean bDebug = true;
		
	protected void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}
	
	public UserGooglePlay(Context context) {
		mContext = context;
		mAdapter = this;
		PluginWrapper.addListener(this);
		mGameHelperListener = new GameHelperListener() {
			@Override
			public void onSignInSucceeded() {
				LogD("Signed In");
				UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "Google Play: signed in");
			}
			
			@Override
			public void onSignInFailed() {
				LogD("Sign In failed.");
				UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_FAILED, "Google Play: login failed");
			}
		};
		mGameHelper = GooglePlayAgent.getInstance().getGameHelper();
		if (mGameHelper == null) {
			LogD("Please call GoogleAgent setup method first.");
		}
	}
	
	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				mGameHelper.setMaxAutoSignInAttempts(0);
				mGameHelper.setup(mGameHelperListener);
//				mGameHelper.setConnectOnStart(false);
				setDebugMode(bDebug);
			}
		});
	}

	@Override
	public void login() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (mGameHelper != null) {
					mGameHelper.beginUserInitiatedSignIn();
				} else {
					Log.e("G+", "Please configure first");
					UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_FAILED, "Google Play: not configured yet.");
				}
			}
		});
	}

	@Override
	public void logout() {
		if (mGameHelper != null) {
			mGameHelper.signOut();
			LogD("Signed out");
			UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "Google Play: logout successful.");
		} else {
			LogD("Please configure first");
			UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGOUT_FAILED, "Google Play: not configured yet.");
		}
	}

	public String getUserId() {
		if (mGameHelper == null || !mGameHelper.isSignedIn())
			return null;
		
		return Games.Players.getCurrentPlayerId(mGameHelper.getApiClient());
	}
	
	@Override
	public boolean isLoggedIn() {
		if (mGameHelper != null)
			return mGameHelper.isSignedIn();
		return false;
	}

	public String getAccessToken() {
		if (mGameHelper == null || !mGameHelper.isSignedIn()) {
			return null;
		}
		try {
			return GoogleAuthUtil.getToken(mContext, getUserId(), "oauth2:https://www.googleapis.com/auth/games");
		} catch (Exception ex) {
			return null;
		}
	}
	
	@Override
	public String getSessionID() {
		if (mGameHelper == null || !mGameHelper.isSignedIn()) {
			return null;
		}
		return "";
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
		if (mGameHelper != null) {
			mGameHelper.enableDebugLog(debug);
		}
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
		if (mGameHelper != null) {
			mGameHelper.onStart((Activity) mContext);
		}
	}

	@Override
	public void onResume() {
	}

	@Override
	public void onPause() {
	}

	@Override
	public void onStop() {
		if (mGameHelper != null) {
			mGameHelper.onStop();
		}
	}

	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		Log.i(LOG_TAG, "RequestCode = " + requestCode);
		Log.i(LOG_TAG, "ResultCode = " + resultCode);
		Log.i(LOG_TAG, "Data = " + data);
		mGameHelper.onActivityResult(requestCode, resultCode, data);
		return true;
	}

	@Override
	public String getUserID() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getUserAvatarUrl() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getUserDisplayName() {
		// TODO Auto-generated method stub
		return null;
	}
}
