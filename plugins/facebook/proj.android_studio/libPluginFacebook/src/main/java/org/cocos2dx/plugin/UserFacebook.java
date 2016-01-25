/****************************************************************************
 Copyright (c) 2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

package org.cocos2dx.plugin;

import java.util.Arrays;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Set;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.facebook.Profile;
import com.facebook.AccessToken;
import com.facebook.AccessTokenTracker;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookRequestError;
import com.facebook.FacebookSdk;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.HttpMethod;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

public class UserFacebook implements InterfaceUser, PluginListener {
	private final static String LOG_TAG = "UserFacebook";
	private Activity mContext = null;
	private InterfaceUser mAdapter = null;
	private boolean bDebug = true;
	private CallbackManager mCallbackManager = null;
	private AccessTokenTracker mAccessTokenTracker = null;
	private AccessToken mAccessToken = null;

	protected void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public UserFacebook(Context context) {
		mContext = (Activity) context;
		FacebookSdk.sdkInitialize(mContext.getApplicationContext());
		PluginWrapper.addListener(this);
		mAdapter = this;
		mCallbackManager = CallbackManager.Factory.create();
		mAccessTokenTracker = new AccessTokenTracker() {

			@Override
			protected void onCurrentAccessTokenChanged(
					AccessToken oldAccessToken, AccessToken currentAccessToken) {
				mAccessToken = currentAccessToken;
			}
		};
		mAccessToken = AccessToken.getCurrentAccessToken();

		LoginManager.getInstance().registerCallback(mCallbackManager,
				new FacebookCallback<LoginResult>() {

					@Override
					public void onSuccess(LoginResult result) {
						LogD("Login facebook success");
						UserWrapper.onActionResult(mAdapter,
								UserWrapper.ACTION_RET_LOGIN_SUCCEED,
								"Login facebook success.");
					}

					@Override
					public void onError(FacebookException error) {
						LogD("Login facebook error" + error.getMessage());
						UserWrapper.onActionResult(mAdapter,
								UserWrapper.ACTION_RET_LOGIN_FAILED,
								"Login facebook fail: " + error.getMessage());

					}

					@Override
					public void onCancel() {
						LogD("Login facebook cancel");
						UserWrapper.onActionResult(mAdapter,
								UserWrapper.ACTION_RET_LOGIN_FAILED,
								"Login facebook be cancelled");
					}
				});
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
	}

	public void loginWithPublishPermissions(String permissions) {
		String[] arr = permissions.split(",");

		if (mAccessToken != null && !mAccessToken.isExpired()) {
			if (mAccessToken.getPermissions().containsAll(Arrays.asList(arr))) {
				UserWrapper.onActionResult(mAdapter,
						UserWrapper.ACTION_RET_LOGIN_SUCCEED,
						"Login facebook already.");
			}
		} else {
			LoginManager.getInstance().logInWithPublishPermissions(
					(Activity) mContext, Arrays.asList(arr));
		}
	}

	public void loginWithReadPermissions(String permissions) {
		String[] arr = permissions.split(",");

		if (mAccessToken != null && !mAccessToken.isExpired()) {
			if (mAccessToken.getPermissions().containsAll(Arrays.asList(arr))) {
				UserWrapper.onActionResult(mAdapter,
						UserWrapper.ACTION_RET_LOGIN_SUCCEED,
						"Login facebook already.");
			}
		} else {
			LoginManager.getInstance().logInWithReadPermissions(
					(Activity) mContext, Arrays.asList(arr));
		}
	}

	@Override
	public void login() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				loginWithReadPermissions("public_profile, email, user_friends");
			}
		});
	}

	@Override
	public void logout() {
		Log.i(LOG_TAG, mAccessToken == null ? "mAccessToken is null" : "mAccessToken is NOT null");
		if (mAccessToken != null) {
			LoginManager.getInstance().logOut();
			mAccessToken = null;
			UserWrapper.onActionResult(mAdapter,
					UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "Facebook logout");
		} else {
			UserWrapper.onActionResult(mAdapter,
					UserWrapper.ACTION_RET_LOGOUT_FAILED,
					"Facebook logout already.");
		}
	}

	@Override
	public String getUserID() {
		if (mAccessToken != null)
			return mAccessToken.getUserId();
		return null;
	}

	@Override
	public String getUserAvatarUrl() {
		return null;
	}
	
	public String getUserFullName() {
		return Profile.getCurrentProfile().getName();
	}
	
	public String getUserLastName() {
		return Profile.getCurrentProfile().getLastName();
	}
	
	public String getUserFirstName() {
		return Profile.getCurrentProfile().getFirstName();
	}
	
	@Override
	public String getUserDisplayName() {
		return Profile.getCurrentProfile().getName();
	}
	
	@Override
	public boolean isLoggedIn() {
		return AccessToken.getCurrentAccessToken() != null;
	}

	@Override
	public String getSessionID() {
		return null;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

	@Override
	public String getSDKVersion() {
		return FacebookSdk.getSdkVersion();
	}

	public String getAccessToken() {
		return mAccessToken.getToken();
	}

	public String getPermissionList() {
		if (mAccessToken != null) {

			StringBuffer buffer = new StringBuffer();
			Set<String> permissions = mAccessToken.getPermissions();

			for (Iterator<String> iter = permissions.iterator(); iter.hasNext();) {
				buffer.append(iter.next());
				if (iter.hasNext())
					buffer.append(',');
			}

			return buffer.toString();
		}

		return null;
	}

	public void graphRequest(final String graphPath, final JSONObject params,
			final long nativeCallback) {
		PluginWrapper.runOnMainThread(new Runnable() {

			@Override
			public void run() {
				if (mAccessToken != null) {
					try {
						Bundle parameter = new Bundle();
						Iterator<?> it = params.keys();
						while (it.hasNext()) {
							String key = it.next().toString();
							String value = params.getString(key);
							parameter.putString(key, value);
						}

						GraphRequest request = GraphRequest
								.newGraphPathRequest(mAccessToken, graphPath,
										new GraphRequest.Callback() {

											@Override
											public void onCompleted(
													GraphResponse response) {
												LogD(response.toString());

												FacebookRequestError error = response
														.getError();

												if (error == null) {
													nativeRequestCallback(
															UserWrapper.GRAPH_RET_SUCCESS,
															response.getJSONObject()
																	.toString(),
															nativeCallback);
												} else {
													nativeRequestCallback(
															UserWrapper.GRAPH_RET_FAILED,
															"{\"error_message\":\""
																	+ error.getErrorMessage()
																	+ "\"}",
															nativeCallback);
												}
											}
										});

						request.executeAsync();
					} catch (JSONException e) {
						e.printStackTrace();
						nativeRequestCallback(UserWrapper.GRAPH_RET_FAILED,
								"{\"error_message\":\"" + e.getMessage()
										+ "\"}", nativeCallback);
					}
				} else {
					nativeRequestCallback(UserWrapper.GRAPH_RET_FAILED,
							"{\"error_message\":\" Not login yet.\"}",
							nativeCallback);
				}
			}
		});
	}

	public void graphRequestWithParams(final JSONObject info) {
		try {
			String graphPath = info.getString("Param1");
			JSONObject jsonParameters = info.getJSONObject("Param2");
			long nativeCallback = info.getLong("Param3");

			graphRequest(graphPath, jsonParameters, nativeCallback);
		} catch (JSONException ex) {
			ex.printStackTrace();
		}
	}

	public void api(final String graphPath, final int method,
			final JSONObject jsonParams, final long nativeCallback) {
		PluginWrapper.runOnMainThread(new Runnable() {

			@Override
			public void run() {
				if (mAccessToken != null) {
					try {
						Bundle parameter = new Bundle();
						Iterator<?> it = jsonParams.keys();
						while (it.hasNext()) {
							String key = it.next().toString();
							String value = jsonParams.getString(key);
							parameter.putString(key, value);
						}

						GraphRequest request = new GraphRequest(mAccessToken,
								graphPath, parameter,
								HttpMethod.values()[method],
								new GraphRequest.Callback() {
									@Override
									public void onCompleted(
											GraphResponse response) {
										LogD(response.toString());

										FacebookRequestError error = response
												.getError();

										if (error == null) {
											nativeRequestCallback(
													UserWrapper.GRAPH_RET_SUCCESS,
													response.getJSONObject()
															.toString(),
													nativeCallback);
										} else {
											nativeRequestCallback(
													UserWrapper.GRAPH_RET_FAILED,
													"{\"error_message\":\""
															+ error.getErrorMessage()
															+ "\"}",
													nativeCallback);
										}
									}
								});

						request.executeAsync();
					} catch (JSONException e) {
						e.printStackTrace();
						nativeRequestCallback(UserWrapper.GRAPH_RET_FAILED,
								"{\"error_message\":\"" + e.getMessage()
										+ "\"}", nativeCallback);
					}
				} else {
					nativeRequestCallback(UserWrapper.GRAPH_RET_FAILED,
							"{\"error_message\":\" Not login yet.\"}",
							nativeCallback);
				}
			}
		});
	}

	public void api(final JSONObject info) {
		try {
			String graphPath = info.getString("Param1");
			int method = info.getInt("Param2");
			JSONObject jsonParameters = info.getJSONObject("Param3");
			long nativeCallback = info.getLong("Param4");

			api(graphPath, method, jsonParameters, nativeCallback);
		} catch (JSONException ex) {
			ex.printStackTrace();
		}
	}

	private native void nativeRequestCallback(int ret, String msg, long cbID);

	@Override
	public void onStart() {
		mAccessTokenTracker.startTracking();
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
		mCallbackManager.onActivityResult(requestCode, resultCode, data);

		return true;
	}
}
