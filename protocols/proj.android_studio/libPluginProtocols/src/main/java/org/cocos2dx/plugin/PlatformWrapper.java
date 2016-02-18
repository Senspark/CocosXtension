package org.cocos2dx.plugin;

public class PlatformWrapper {
	public static final int PLATFORM_RESULT_CODE_kConnected = 1;
	public static final int PLATFORM_RESULT_CODE_kUnconnected = 2;	
	
	public static void onPlatformResult(int ret, String msg) {
        final int curRet = ret;
        final String curMsg = msg;

        PluginWrapper.runOnGLThread(new Runnable() {
            @Override
            public void run() {
                nativeOnPlatformResult(curRet, curMsg);
            }
        });
    }
    private static native void nativeOnPlatformResult(int ret, String msg);
}
