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

import java.util.Hashtable;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.util.Log;

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
import com.facebook.share.widget.ShareDialog;

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
}
