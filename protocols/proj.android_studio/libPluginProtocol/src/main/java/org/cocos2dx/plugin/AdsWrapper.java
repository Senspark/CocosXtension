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

import android.app.Activity;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

public class AdsWrapper {

	public static final int RESULT_CODE_AdsBannerReceived 	= 0;               // The ad is received
	public static final int RESULT_CODE_AdsInterstitialReceived = 1;
	public static final int RESULT_CODE_AdsShown 		= 2;                  // The advertisement shown
    public static final int RESULT_CODE_AdsDismissed 	= 3;              // The advertisement dismissed
    public static final int RESULT_CODE_AdsClicked 		= 4;
    public static final int RESULT_CODE_AdsClosed 		= 5;
    public static final int RESULT_CODE_AdsSkipped 		= 6;
    
    public static final int RESULT_CODE_MoreAppsReceived 	= 7;
    public static final int RESULT_CODE_MoreAppsShown 		= 8;
    public static final int RESULT_CODE_MoreAppsDismissed 	= 9;
    public static final int RESULT_CODE_MoreAppsClicked 	= 10;
    public static final int RESULT_CODE_MoreAppsClosed 		= 11;
    
    public static final int RESULT_CODE_VideoReceived 	= 12;
    public static final int RESULT_CODE_VideoShown 		= 13;
    public static final int RESULT_CODE_VideoDismissed	= 14;
    public static final int RESULT_CODE_VideoCompleted 	= 15;
    public static final int RESULT_CODE_VideoClosed 	= 16;
    public static final int RESULT_CODE_VideoClicked 	= 17;
    
    public static final int RESULT_CODE_PointsSpendSucceed	= 18;        // The points spend succeed
    public static final int RESULT_CODE_PointsSpendFailed 	= 19;         // The points spend failed
    public static final int RESULT_CODE_NetworkError 		= 20;              // Network error
    public static final int RESULT_CODE_UnknownError 		= 21;              // Unknown error

	public static final int POS_CENTER 	     = 0;
	public static final int POS_TOP		     = 1;
	public static final int POS_TOP_LEFT     = 2;
	public static final int POS_TOP_RIGHT    = 3;
	public static final int POS_BOTTOM       = 4;
	public static final int POS_BOTTOM_LEFT  = 5;
	public static final int POS_BOTTOM_RIGHT = 6;
	public static final int POS_BOTTOM_CENTER = 7;

	public static void addAdView(View adView, int pos) {

		FrameLayout mFrameLayout = (FrameLayout) ((Activity) PluginWrapper.getContext()).findViewById(
				android.R.id.content).getRootView();

		FrameLayout.LayoutParams mLayoutParams;
		if (pos == POS_CENTER || pos == POS_BOTTOM_CENTER) {
			mLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
		} else {
			mLayoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
		}

		switch (pos) {
		case POS_CENTER:
			mLayoutParams.gravity = Gravity.CENTER;
			break;
		case POS_TOP:
			mLayoutParams.gravity = Gravity.TOP;
			break;
		case POS_TOP_LEFT:
			mLayoutParams.gravity = Gravity.TOP | Gravity.LEFT;
			break;
		case POS_TOP_RIGHT:
			mLayoutParams.gravity = Gravity.TOP | Gravity.RIGHT;
			break;
		case POS_BOTTOM:
			mLayoutParams.gravity = Gravity.BOTTOM;
			break;
		case POS_BOTTOM_LEFT:
			mLayoutParams.gravity = Gravity.BOTTOM | Gravity.LEFT;
			break;
		case POS_BOTTOM_RIGHT:
			mLayoutParams.gravity = Gravity.BOTTOM | Gravity.RIGHT;
			break;
		case POS_BOTTOM_CENTER:
			mLayoutParams.gravity = Gravity.BOTTOM | Gravity.CENTER;
			break;
		default:
			break;
		}

		mFrameLayout.addView(adView, mLayoutParams);
	}

	public static void onAdsResult(InterfaceAds adapter, int code, String msg) {
		final int curCode = code;
		final String curMsg = msg;
		final InterfaceAds curObj = adapter;
		PluginWrapper.runOnGLThread(new Runnable(){
			@Override
			public void run() {
				String name = curObj.getClass().getName();
				name = name.replace('.', '/');
				AdsWrapper.nativeOnAdsResult(name, curCode, curMsg);
			}
		});
	}
	private native static void nativeOnAdsResult(String className, int code, String msg);
	
	public static void onPlayerGetPoints(InterfaceAds adapter, int points) {
		final int curPoints = points;
		final InterfaceAds curAdapter = adapter;
		PluginWrapper.runOnGLThread(new Runnable(){
			@Override
			public void run() {
				String name = curAdapter.getClass().getName();
				name = name.replace('.', '/');
				AdsWrapper.nativeOnPlayerGetPoints(name, curPoints);
			}
		});
	}
	private native static void nativeOnPlayerGetPoints(String className, int points);
}
