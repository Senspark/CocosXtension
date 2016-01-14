package org.cocos2dx.plugin;


import android.util.Log;

public class BaaSWrapper {
	public static void onBaaSActionResult(InterfaceBaaS adapter, boolean success, String result, long callbackID) {
		final boolean curSuccess = success;
		final String curResult = result;
		final InterfaceBaaS curObj = adapter;
		final long cbID = callbackID;
		
		PluginWrapper.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				Log.i("BaaSWrapper", "Callback address >>> " + cbID);
				BaaSWrapper.nativeOnBaaSActionResult(name, curSuccess, curResult, cbID);
			}
		});
	}
	
	public native static void nativeOnBaaSActionResult(String className, boolean success, String result, long callbackID);
}
