/****************************************************************************
 * Copyright (c) 2012-2013 cocos2d-x.org
 * <p/>
 * http://www.cocos2d-x.org
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.plugin;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;

public class AdsWrapper {
    static class ResultCode {
        static final int BannerAdLoaded          = 40;
        static final int BannerAdFailedToLoad    = 41;
        static final int BannerAdOpened          = 42;
        static final int BannerAdClosed          = 43;
        static final int BannerAdLeftApplication = 44;

        static final int NativeExpressAdLoaded          = 50;
        static final int NativeExpressAdFailedToLoad    = 51;
        static final int NativeExpressAdOpened          = 52;
        static final int NativeExpressAdClosed          = 53;
        static final int NativeExpressAdLeftApplication = 54;

        static final int InterstitialAdLoaded          = 60;
        static final int InterstitialAdFailedToLoad    = 61;
        static final int InterstitialAdOpened          = 62;
        static final int InterstitialAdClosed          = 63;
        static final int InterstitialAdLeftApplication = 64;

        static final int RewardedVideoAdLoaded          = 70;
        static final int RewardedVideoAdFailedToLoad    = 71;
        static final int RewardedVideoAdOpened          = 72;
        static final int RewardedVideoAdStarted         = 73;
        static final int RewardedVideoAdClosed          = 74;
        static final int RewardedVideoAdRewarded        = 75;
        static final int RewardedVideoAdLeftApplication = 76;
    }

    /// Called when an interstitial ad was shown and user click on
    /// an in-app purchase butotn
    public static final int RESULT_CODE_InAppPurchaseRequested = 100;

    public static void onAdsResult(InterfaceAds adapter, int code, String msg) {
        final int curCode = code;
        final String curMsg = msg;
        final InterfaceAds curObj = adapter;
        PluginWrapper.runOnGLThread(new Runnable() {
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
        PluginWrapper.runOnGLThread(new Runnable() {
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
