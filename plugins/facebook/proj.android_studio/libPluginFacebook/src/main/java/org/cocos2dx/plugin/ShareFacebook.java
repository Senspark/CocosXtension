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
import com.facebook.share.Sharer;
import com.facebook.share.Sharer.Result;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.model.ShareVideo;
import com.facebook.share.model.ShareVideoContent;
import com.facebook.share.widget.LikeView;
import com.facebook.share.widget.ShareDialog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Hashtable;

public class ShareFacebook implements InterfaceShare{

	private static Activity mContext = null;
	private static InterfaceShare mAdapter = null;
	private static boolean bDebug = true;
	private final static String LOG_TAG = "ShareFacebook";
	private ShareDialog mShareDialog = null;
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
		mAdapter = this;
		mShareDialog = new ShareDialog((Activity) mContext);
		mCallbackManager = CallbackManager.Factory.create();
		
		mShareDialog.registerCallback(mCallbackManager, new FacebookCallback<Sharer.Result>() {
			
			@Override
			public void onSuccess(Result result) {
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_SUCCESS, "{\"didComplete\":true}");
			}
			
			@Override
			public void onError(FacebookException error) {
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, "{ \"error_message\" : \"" + error.getMessage() + "\"}");
			}
			
			@Override
			public void onCancel() {
				ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, "{ \"error_message\" : \" user cancelled\"}");
			}
		});
	}
    
	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		LogD("no need to config.");
	}
	
	

	@Override
	public void share(final Hashtable<String, String> cpInfo) {
		LogD("share invoked " + cpInfo.toString());
		
		if (networkReachable()) {
			PluginWrapper.runOnMainThread(new Runnable() {
				@Override
				public void run() {
					String link = cpInfo.get("link");
					String photo = cpInfo.get("photo");
					String video = cpInfo.get("video");
					
					if (link != null) {
					
						String caption = cpInfo.get("caption");
						String description = cpInfo.get("description");
						String picture = cpInfo.get("picture");
						
						ShareLinkContent.Builder builder = new ShareLinkContent.Builder();
						
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
						
						ShareWrapper.onShareResult(mAdapter, ShareWrapper.SHARERESULT_FAIL, object.toString());
					}
				}
			});
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
}
