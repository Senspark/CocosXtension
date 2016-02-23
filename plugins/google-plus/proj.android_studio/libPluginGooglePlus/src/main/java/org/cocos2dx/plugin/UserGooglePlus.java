package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.plus.Plus;

import java.util.Hashtable;

public class UserGooglePlus implements InterfaceUser, PluginListener, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {
	protected static final String LOG_TAG = "UserGooglePlus";
	
	protected GoogleApiClient mGoogleApiClient;
	protected Context mContext;
	protected UserGooglePlus mAdapter;
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
	
	public UserGooglePlus(Context context) {
		mContext = context;
		mAdapter = this;
		PluginWrapper.addListener(this);
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		GoogleApiClient.Builder builder = new GoogleApiClient.Builder(mContext);
		builder.addConnectionCallbacks(mAdapter);
		builder.addOnConnectionFailedListener(mAdapter);
		builder.addApi(Plus.API);
		builder.addScope(new Scope(Scopes.PLUS_ME));
		builder.addScope(new Scope(Scopes.PLUS_LOGIN));
		
		mGoogleApiClient = builder.build();
	}

	@Override
	public void login() {
		mShouldResolve = true;
		mGoogleApiClient.connect();
	}

	@Override
	public void logout() {
		if (mGoogleApiClient.isConnected()) {
			mGoogleApiClient.disconnect();
		}
	}

	@Override
	public boolean isLoggedIn() {
		return mGoogleApiClient.isConnected();
	}

	@Override
	public void onStart() {
		mGoogleApiClient.connect();
	}

	@Override
	public void onResume() {
		
	}

	@Override
	public void onPause() {
		
	}

	@Override
	public void onStop() {
		if (mGoogleApiClient.isConnected()) {
			mGoogleApiClient.disconnect();
		}
	}

	@Override
	public void onDestroy() {
		
	}

	@Override
	public void onBackPressed() {
		
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

		Log.i(LOG_TAG, "RequestCode = " + requestCode);
		Log.i(LOG_TAG, "ResultCode = " + resultCode);
		Log.i(LOG_TAG, "Data = " + data);

		if (requestCode == RC_SIGN_IN) {
			if (resultCode != RESULT_OK) {
				mShouldResolve = false;
				UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_FAILED, "UserGooglePlus: Login failed");
			} else {
				mIsResolving = false;
				mGoogleApiClient.connect();
				UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "UserGooglePlus: Login succeeded");
			}
		}
		return true;
	}

	@Override
	public String getSessionID() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getUserID() {
		return Plus.PeopleApi.getCurrentPerson(mGoogleApiClient).getId();
	}

	@Override
	public String getUserAvatarUrl() {
		return Plus.PeopleApi.getCurrentPerson(mGoogleApiClient).getImage().getUrl();
	}

	@Override
	public String getUserDisplayName() {
		return Plus.PeopleApi.getCurrentPerson(mGoogleApiClient).getDisplayName();
	}

	@Override
	public void setDebugMode(boolean debug) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public String getSDKVersion() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public String getPluginVersion() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void onConnectionFailed(ConnectionResult result) {
		if (!mIsResolving && mShouldResolve) {
			if (result.hasResolution()) {
				try {
					result.startResolutionForResult((Activity) mContext, RC_SIGN_IN);
				} catch (IntentSender.SendIntentException e) {
					mIsResolving = false;
					mGoogleApiClient.connect();
				}
			}
		}
	}

	@Override
	public void onConnected(Bundle connectionHint) {
		mShouldResolve = false;
		UserWrapper.onActionResult(mAdapter, UserWrapper.ACTION_RET_LOGIN_SUCCEED, "UserGooglePlus: Login succeeded");
	}

	@Override
	public void onConnectionSuspended(int cause) {
		// TODO Auto-generated method stub
		
	}
}
