/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

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

public class UserWrapper {
	public static final int ACTION_RET_LOGIN_SUCCEED = 0;
    public static final int ACTION_RET_LOGIN_FAILED = 1;
    public static final int ACTION_RET_LOGOUT_SUCCEED = 2;
    public static final int ACTION_RET_LOGOUT_FAILED = 3;

    public static final int GRAPH_RET_SUCCESS = 4;
    public static final int GRAPH_RET_FAILED = 5;
	public static final int GRAPH_RET_CANCEL = 6;
    public static final int GRAPH_RET_TIMEOUT = 7;

	public static final int PERMISSION_LIST_RET_SUCCESS = 8;
	public static final int PERMISSION_LIST_RET_FAILED = 9;
	public static final int PERMISSION_USER_RET_SUCCESS = 10;
	public static final int PERMISSION_USER_RET_FAILED = 11;

	public static void onActionResult(InterfaceUser obj, int ret, String msg) {
		final int curRet = ret;
		final String curMsg = msg;
		final InterfaceUser curAdapter = obj;
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = curAdapter.getClass().getName();
				name = name.replace('.', '/');
				nativeOnActionResult(name, curRet, curMsg);
			}
		});
	}

	public static void onGraphRequestResult(InterfaceUser obj, int ret, String msg, int cbId) {
		final int curRet = ret;
		final int curCBId = cbId;
		final String curMsg = msg;
		final InterfaceUser curAdapter = obj;
		PluginWrapper.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				String name = curAdapter.getClass().getName();
				name = name.replace('.', '/');
				nativeOnGraphRequestResultFrom(name, curRet, curMsg, curCBId);
			}
		});
	}
	
	private static native void nativeOnActionResult(String className, int ret, String msg);
	private static native void nativeOnGraphRequestResultFrom(String className, int ret, String msg, int cbId);
}
