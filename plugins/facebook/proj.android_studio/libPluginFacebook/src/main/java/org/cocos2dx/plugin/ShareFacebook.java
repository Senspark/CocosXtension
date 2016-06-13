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

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.view.ContextThemeWrapper;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.internal.CallbackManagerImpl;
import com.facebook.share.Sharer;
import com.facebook.share.Sharer.Result;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.ShareVideo;
import com.facebook.share.model.ShareVideoContent;
import com.facebook.share.widget.GameRequestDialog;
import com.facebook.share.widget.LikeView;
import com.facebook.share.widget.ShareDialog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.Hashtable;

public class ShareFacebook implements InterfaceShare, PluginListener {

	private static Activity mContext = null;
	private static InterfaceShare mAdapter = null;
	private static boolean bDebug = true;
	private final static String LOG_TAG = "ShareFacebook";
	private CallbackManager mCallbackManager = null;
	
	protected static void LogE(String msg, Exception e) {
        Log.e(LOG_TAG, msg, e);
        e.printStackTrace();
    }

    protected static void LogD(String msg) {
        if (bDebug) {
            Log.d(LOG_TAG, msg);
        }
    }
    
    public ShareFacebook(Context context) {
		mContext = (Activity)context;
		FacebookSdk.sdkInitialize(mContext.getApplicationContext());
		PluginWrapper.addListener(this);
		mAdapter = this;
		mCallbackManager = CallbackManager.Factory.create();
	}
    
	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		LogD("no need to config.");
	}


	@Override
	public void share(final Hashtable<String, String> cpInfo, final int callbackID) {
		LogD("share invoked " + cpInfo.toString());

		if (networkReachable()) {
			ShareDialog mShareDialog = new ShareDialog(mContext);

			mShareDialog.registerCallback(mCallbackManager, new FacebookCallback<Sharer.Result>() {

				@Override
				public void onSuccess(Result result) {
					Log.i(LOG_TAG, "Share fb succeeded with postID: " + result.getPostId());
					ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_SUCCESS, cpInfo, "Share Facebook Succeeded", callbackID);
				}

				@Override
				public void onError(FacebookException error) {
					Log.e(LOG_TAG, "Share fb failed with error: " + error.getMessage());
					ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, cpInfo, "Share Facebook Failed with error: " + error.getMessage(), callbackID);
				}

				@Override
				public void onCancel() {
					Log.i(LOG_TAG, "Share fb cancelled by user");
					ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, cpInfo, "Share Facebook Cancelled by user", callbackID);
				}
			});

			String link = cpInfo.get("link");
			String photo = cpInfo.get("photo");
			String video = cpInfo.get("video");

			if (link != null) {

				String caption = cpInfo.get("caption");
				String description = cpInfo.get("description");
				String picture = cpInfo.get("picture");

				ShareLinkContent.Builder builder = new ShareLinkContent.Builder();

				builder.setContentUrl(Uri.parse(link));
				builder.setContentDescription(description);
				builder.setContentTitle(caption);
				builder.setImageUrl(Uri.parse(picture));

				if (ShareDialog.canShow(ShareLinkContent.class)) {
					mShareDialog.show(builder.build());
				}
			} else if (photo != null) {
				SharePhotoContent.Builder builder = new SharePhotoContent.Builder();

				SharePhoto.Builder photoBuilder = new SharePhoto.Builder();
				photoBuilder.setBitmap(BitmapFactory.decodeFile(photo));

				builder.addPhoto(photoBuilder.build());

				if (ShareDialog.canShow(SharePhotoContent.class)) {
					mShareDialog.show(builder.build());
				}
			} else if (video != null) {
				ShareVideoContent.Builder builder = new ShareVideoContent.Builder();

				ShareVideo.Builder videoBuilder = new ShareVideo.Builder();
				videoBuilder.setLocalUrl(Uri.parse(video));

				if (ShareDialog.canShow(ShareVideoContent.class)) {
					mShareDialog.show(builder.build());
				}
			} else {
				JSONObject object = new JSONObject();

				try {
					object.accumulate("error_message", "Share failed, share target absent or not supported, please add 'siteUrl' or 'imageUrl' in parameters");
				} catch (JSONException ex) {

				}

				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, cpInfo, object.toString(), callbackID);
			}
		}
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;		
	}

	@Override
	public String getPluginVersion() {
		return "0.2.0";
	}

	@Override
	public String getSDKVersion() {
		return FacebookSdk.getSdkVersion();
	}

	private boolean networkReachable() {
		boolean bRet = false;
		try {
			ConnectivityManager conn = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
			NetworkInfo netInfo = conn.getActiveNetworkInfo();
			bRet = (null == netInfo) ? false : netInfo.isAvailable();
		} catch (Exception e) {
			LogE("Fail to check network status", e);
		}
		LogD("NetWork reachable : " + bRet);
		return bRet;
	}

	void sendGameRequest(final Hashtable<String, String> info, final int callbackID) {

		Log.i(LOG_TAG, "Info: " + info);
		Log.i(LOG_TAG, "CallbackID: " + callbackID);

		String recipients	= info.get("recipients");
		String[] recipientsArray = recipients.split(",");
		String title		= info.get("title");
		String message		= info.get("message");
		String objectID		= info.get("object-id");
		String data			= info.get("data");

		GameRequestDialog gameRequestDialog 	= new GameRequestDialog(mContext);
		gameRequestDialog.registerCallback(mCallbackManager, new FacebookCallback<GameRequestDialog.Result>() {
			@Override
			public void onSuccess(GameRequestDialog.Result result) {
				Log.i(LOG_TAG, "Send gift succeeded to: " + result.getRequestRecipients());
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_SUCCESS, info, "success", callbackID);
			}

			@Override
			public void onCancel() {
				Log.e(LOG_TAG, "Send gift cancelled by user");
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_CANCEL, info, "cancel", callbackID);
			}

			@Override
			public void onError(FacebookException error) {
				Log.e(LOG_TAG, "Send gift failed with error: " + error.getMessage());
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, info, error.getMessage(), callbackID);
			}
		});

		if (data != null && objectID != null) { // Send gift, item, etc.
			GameRequestContent gameRequestContent = new GameRequestContent.Builder()
					.setMessage(message)
					.setTitle(title)
					.setObjectId(objectID)
					.setActionType(GameRequestContent.ActionType.SEND)
					.setData(data)
					.setRecipients(Arrays.asList(recipientsArray))
					.build();
			gameRequestDialog.show(gameRequestContent);

		} else { // Send invitation
			GameRequestContent gameRequestContent = new GameRequestContent.Builder()
					.setMessage(message)
					.setTitle(title)
					.setRecipients(Arrays.asList(recipientsArray))
					.build();
			gameRequestDialog.show(gameRequestContent);
		}
	}


	public void likeFanpage(final String idFacebookPage) {

		PluginWrapper.runOnMainThread(new Runnable() {
			@TargetApi(Build.VERSION_CODES.HONEYCOMB)
			@Override
			public void run() {
				String pageToLike = "https://www.facebook.com/" + idFacebookPage;
				Log.i("Like API", "Page to like: " + pageToLike);

				LikeView likeView = new LikeView(mContext);
				likeView.setLikeViewStyle(LikeView.Style.STANDARD);
				likeView.setAuxiliaryViewPosition(LikeView.AuxiliaryViewPosition.BOTTOM);
				likeView.setObjectIdAndType(pageToLike, LikeView.ObjectType.PAGE);
				likeView.setEnabled(true);

				LinearLayout ll = new LinearLayout(mContext);
				ll.setOrientation(LinearLayout.VERTICAL);
				ll.addView(likeView);

				TextView title = new TextView(mContext);
				// You Can Customise your Title here
				title.setText("Facebook Like");
				title.setPadding(10, 10, 10, 10);
				title.setGravity(Gravity.CENTER);
				title.setTextColor(Color.BLACK);
				title.setTextSize(20);

				final int flags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
						| View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
						| View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
						| View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
						| View.SYSTEM_UI_FLAG_FULLSCREEN
						| View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;

				if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
					Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(mContext, android.R.style.Theme_Holo_Light_Dialog));
					builder.setCustomTitle(title);
					builder.setMessage("Like us and never miss out on awesome events!");
					builder.setView(ll);

					AlertDialog dialog = builder.create();
					dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
					dialog.show();

					dialog.getWindow().getDecorView().setSystemUiVisibility(flags);
					TextView textView = (TextView) dialog.findViewById(android.R.id.message);
					textView.setTextSize(17);

				} else {
					Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(mContext, android.R.style.Theme_Holo_Light_Dialog));
					builder.setCustomTitle(title);
					builder.setMessage("Like us and never miss out on awesome events!");
					builder.setView(ll);

					AlertDialog dialog = builder.create();
					dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
					dialog.show();

					dialog.getWindow().getDecorView().setSystemUiVisibility(flags);
					TextView textView = (TextView) dialog.findViewById(android.R.id.message);
					textView.setTextSize(17);
				}
			}
		});
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
        Log.i(LOG_TAG, "onActivityResult triggered");
        Log.i(LOG_TAG, "RequestCode: " + requestCode);
        Log.i(LOG_TAG, "ResultCode: " + resultCode);
        Log.i(LOG_TAG, "Data: " + data);

        Log.i(LOG_TAG, "RequestCodeOffset - Share: " + CallbackManagerImpl.RequestCodeOffset.Share.toRequestCode()
                + " - GameRequest: " + CallbackManagerImpl.RequestCodeOffset.GameRequest.toRequestCode()
                + " - AppInvite: " + CallbackManagerImpl.RequestCodeOffset.AppInvite.toRequestCode()
                + " - Like: " + CallbackManagerImpl.RequestCodeOffset.Like.toRequestCode());


        if (requestCode == CallbackManagerImpl.RequestCodeOffset.Share.toRequestCode() ||
                requestCode == CallbackManagerImpl.RequestCodeOffset.GameRequest.toRequestCode() ||
                requestCode == CallbackManagerImpl.RequestCodeOffset.AppInvite.toRequestCode() ||
                requestCode == CallbackManagerImpl.RequestCodeOffset.Like.toRequestCode()) {
            Log.i(LOG_TAG, "CallbackManager onActivityResult triggered");
            mCallbackManager.onActivityResult(requestCode, resultCode, data);
        }

        return true;
    }

}
