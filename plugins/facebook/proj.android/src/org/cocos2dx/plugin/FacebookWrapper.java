package org.cocos2dx.plugin;

import com.facebook.CallbackManager;
import com.facebook.FacebookSdk;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class FacebookWrapper {
	
	protected static CallbackManager sCallbackManager;
	
	public static void onCreate(Activity activity){
		FacebookSdk.sdkInitialize(activity.getApplicationContext());
		sCallbackManager = CallbackManager.Factory.create();
	}
	
	public static void onAcitivityResult(int requestCode, int resultCode, Intent data){
	}
	
	public static void onSaveInstanceState(Bundle outState) {
	}
	
}
