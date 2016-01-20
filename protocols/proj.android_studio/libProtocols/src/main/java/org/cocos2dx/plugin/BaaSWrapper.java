package org.cocos2dx.plugin;

import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class BaaSWrapper {
	public static void onBaaSActionResult(InterfaceBaaS adapter, int code, String result, long callbackID) {
		final int curCode = code;
		final String curResult = result;
		final InterfaceBaaS curObj = adapter;
		final long cbID = callbackID;
		
		PluginWrapper.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				Log.i("BaaSWrapper", "Callback address >>> " + cbID);
				BaaSWrapper.nativeOnBaaSActionResult(name, curCode, curResult, cbID);
			}
		});
	}
	
	public native static void nativeOnBaaSActionResult(String className, int code, String result, long callbackID);
}
