package org.cocos2dx.plugin;

public class DataWrapper {
	public static void onDataResult(final InterfaceData adapter, final int code, final byte[] data) {
		
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = adapter.getClass().getName();
				name = name.replace('.', '/');
				DataWrapper.nativeOnDataResult(name, code, data);
			}
		});
	}
	
	private native static void nativeOnDataResult(String className, int code, byte[] data);
}
