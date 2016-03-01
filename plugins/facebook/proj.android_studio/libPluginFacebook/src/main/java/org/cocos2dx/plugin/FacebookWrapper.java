package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;

public class FacebookWrapper {
	
	protected static CallbackManager sCallbackManager;
	
	public static void onCreate(Activity activity){
		Log.i("FacebookWrapper", "FacebookWrapper onCreate");
		FacebookSdk.sdkInitialize(activity.getApplicationContext());
		sCallbackManager = CallbackManager.Factory.create();
	}
	
	public static void onActivityResult(int requestCode, int resultCode, Intent data){
	}
	
	public static void onSaveInstanceState(Bundle outState) {
	}
	
}
