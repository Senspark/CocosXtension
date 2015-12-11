package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.auth.GoogleAuthUtil;
import com.google.android.gms.auth.api.signin.GoogleSignInConfig;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.plus.Plus;
import com.google.android.gms.signin.GoogleSignInAccount;
import com.google.games.utils.GameHelper;
import com.google.games.utils.GameHelper.GameHelperListener;

public class UserGooglePlay implements InterfaceUser, PluginListener, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {
	protected static final String LOG_TAG = "UserGooglePlay";
	
	protected Context mContext;
	protected UserGooglePlay mUserGooglePlay;
	protected GameHelper mGameHelper;
	protected GameHelperListener mGameHelperListener;
	protected boolean bDebug = true;
    private static final int RC_SIGN_IN = 0;
    private static final int RESULT_OK = -1;
	
    /* Is there a ConnectionResult resolution in progress? */
    private boolean mIsResolving = false;

    /* Should we automatically resolve ConnectionResults when possible? */
    private static boolean mShouldResolve = false;

	
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
		mUserGooglePlay = this;
		PluginWrapper.addListener(this);
		mGameHelperListener = new GameHelperListener() {
			@Override
			public void onSignInSucceeded() {
				LogD("Signed In");
				UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "Google Play: signed in");
			}
			
			@Override
			public void onSignInFailed() {
				LogD("Sign In failed.");
				UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_FAILED, "Google Play: login failed");
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
				mGameHelper.setup(mGameHelperListener);
				mGameHelper.setMaxAutoSignInAttempts(0);
				setDebugMode(bDebug);
			}
		});
	}

	@Override
	public void login() {
		if (mGameHelper != null) {
			mShouldResolve = true;
			mGameHelper.beginUserInitiatedSignIn();
		} else {
			Log.e("G+", "Please configure first");
			UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_FAILED, "Google Play: not configured yet.");
		}				
	}

	@Override
	public void logout() {
		if (mGameHelper != null) {
			mGameHelper.signOut();
			LogD("Signed out");
			UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "Google Play: logout successful.");
		} else {
			LogD("Please configure first");
			UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGOUT_FAILED, "Google Play: not configured yet.");
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
		return String.valueOf(mGameHelper.getApiClient().getSessionId());
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
			Log.e("G+", "onStart");
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
			Log.e("G+", "onStop");
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
		mGameHelper.onActivityResult(requestCode, resultCode, data);
		Log.e("G+", "Request Code: " + requestCode);
		Log.e("G+", "Result Code: " + resultCode);
		if (requestCode == RC_SIGN_IN) {
			if (resultCode != RESULT_OK) {
				Log.e("G+", "G+ failed");
				mShouldResolve = false;
				UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_FAILED, "[Google+]: Logged in G+ failed.");
			} else {
				Log.e("G+", "G+ succeeded");
				mIsResolving = false;
				mGameHelper.getApiClient().connect();
				UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "[Google+]: Logged in G+ succeeded.");
			}
		}
		return true;
	}

	@Override
	public String getUserIdentifier() {
		return Plus.PeopleApi.getCurrentPerson(mGameHelper.getApiClient()).getId();
	}

	@Override
	public String getUserAvatarUrl() {
		return Plus.PeopleApi.getCurrentPerson(mGameHelper.getApiClient()).getImage().getUrl();
	}

	@Override
	public String getUserDisplayName() {
		return Plus.PeopleApi.getCurrentPerson(mGameHelper.getApiClient()).getDisplayName();
	}

	@Override
	public void onConnectionFailed(ConnectionResult result) {
		Log.e("G+", "mIsResolving: " + mIsResolving);
		Log.e("G+", "mShouldResolve: " + mShouldResolve);
		Log.e("G+", "result.hasResolution: " + result.hasResolution());
		if (!mIsResolving && mShouldResolve) {
			if (result.hasResolution()) {
				try {
					Log.e("G+", "Start Resolution For Result: " + result);
					result.startResolutionForResult((Activity) mContext, RC_SIGN_IN);
					mIsResolving = true;
				} catch (IntentSender.SendIntentException e) {
					Log.e("G+", "Could not resolving connection result: ", e);
					mIsResolving = false;
					mGameHelper.beginUserInitiatedSignIn();
				}
			}
		}
	}

	@Override
	public void onConnected(Bundle connectionHint) {
		Log.e("G+", "G+ onConnected");
		mShouldResolve = false;
		UserWrapper.onActionResult(mUserGooglePlay, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "[Google+]: Logged in succeeded.");
	}

	@Override
	public void onConnectionSuspended(int cause) {
		Log.e("G+", "[Google+]: Logged in failed.");
	}	
}
