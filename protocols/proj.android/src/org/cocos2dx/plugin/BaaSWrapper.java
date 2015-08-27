package org.cocos2dx.plugin;


public class BaaSWrapper {
	public static void onActionResult(InterfaceBaaS adapter, int code, String result) {
		final int curCode = code;
		final String curResult = result;
		final InterfaceBaaS curObj = adapter;
		
		PluginWrapper.runOnGLThread(new Runnable() {
			
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				BaaSWrapper.nativeOnActionResult(name, curCode, curResult);
			}
		});
	}
	
	private native static void nativeOnActionResult(String className, int code, String result);
}
