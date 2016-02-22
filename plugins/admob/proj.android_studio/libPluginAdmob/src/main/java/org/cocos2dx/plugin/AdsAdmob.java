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

import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Set;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.cocos2dx.libAdsAdmob.R;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

public class AdsAdmob implements InterfaceAds {

	private static final String LOG_TAG = "AdsAdmob";
	private static Activity mContext = null;
	private static boolean bDebug = false;
	private static AdsAdmob mAdapter = null;
	private int slideUpTimePeriod;
	private int slideDownTimePeriod;

	private AdView adView = null;
	private InterstitialAd interstitialAdView = null;
	private String mPublishID = "";
	private Set<String> mTestDevices = null;
	private WindowManager mWm = null;

	private static final int ADMOB_SIZE_BANNER = 1;
	private static final int ADMOB_SIZE_FULL_BANNER = 2;
	private static final int ADMOB_SIZE_LARGE_BANNER = 3;
	private static final int ADMOB_SIZE_LEADERBOARD = 4;
	private static final int ADMOB_SIZE_MEDIUM_RECTANGLE = 5;
	private static final int ADMOB_SIZE_WIDE_SKYSCRAPER = 6;
	private static final int ADMOB_SIZE_SMART_BANNER = 7;

	private static final int ADMOB_TYPE_BANNER = 1;
	private static final int ADMOB_TYPE_FULLSCREEN = 2;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAdmob(Context context) {
		mContext = (Activity) context;
		mAdapter = this;
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "6.3.1";
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		try {
			mPublishID = devInfo.get("AdmobID");
			LogD("init AppInfo : " + mPublishID);
		} catch (Exception e) {
			LogE("initAppInfo, The format of appInfo is wrong", e);
		}
	}

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
	    try
	    {
	        String strType = info.get("AdmobType");
	        int adsType = Integer.parseInt(strType);

	        switch (adsType) {
	        case ADMOB_TYPE_BANNER:
	            {
	                String strSize = info.get("AdmobSizeEnum");
	                int sizeEnum = Integer.parseInt(strSize);
    	            showBannerAd(sizeEnum, pos);
                    break;
	            }
	        case ADMOB_TYPE_FULLSCREEN:
	            LogD("Now not support full screen view in Admob");
	            break;
	        default:
	            break;
	        }
	    } catch (Exception e) {
	        LogE("Error when show Ads ( " + info.toString() + " )", e);
	    }
	}
	
	@Override
	public void spendPoints(int points) {
		LogD("Admob not support spend points!");
	}

	@Override
	public void hideAds(Hashtable<String, String> info) {
	    try
        {
            String strType = info.get("AdmobType");
            int adsType = Integer.parseInt(strType);

            switch (adsType) {
            case ADMOB_TYPE_BANNER:
                hideBannerAd();
                break;
            case ADMOB_TYPE_FULLSCREEN:
                LogD("Now not support full screen view in Admob");
                break;
            default:
                break;
            }
        } catch (Exception e) {
            LogE("Error when hide Ads ( " + info.toString() + " )", e);
        }
	}

	private void showBannerAd(int sizeEnum, int pos) {
		final int curPos = pos;
		final int curSize = sizeEnum;

		PluginWrapper.runOnMainThread(new Runnable() {

			@Override
			public void run() {
				// destory the ad view before
				if (null != adView) {
					if (null != mWm) {
						mWm.removeView(adView);
					}
					adView.destroy();
					adView = null;
				}

				AdSize size = AdSize.BANNER;
				switch (curSize) {
					case AdsAdmob.ADMOB_SIZE_BANNER:
						size = AdSize.BANNER;
						break;
					case AdsAdmob.ADMOB_SIZE_FULL_BANNER:
						size = AdSize.FULL_BANNER;
						break;
					case AdsAdmob.ADMOB_SIZE_LARGE_BANNER:
						size = AdSize.LARGE_BANNER;
						break;
					case AdsAdmob.ADMOB_SIZE_LEADERBOARD:
						size = AdSize.LEADERBOARD;
						break;
					case AdsAdmob.ADMOB_SIZE_MEDIUM_RECTANGLE:
						size = AdSize.MEDIUM_RECTANGLE;
						break;
					case AdsAdmob.ADMOB_SIZE_SMART_BANNER:
						size = AdSize.SMART_BANNER;
						break;
					case AdsAdmob.ADMOB_SIZE_WIDE_SKYSCRAPER:
						size = AdSize.WIDE_SKYSCRAPER;
						break;
					default:
						break;
				}
				if (adView == null) {
					adView = new AdView(mContext);
				}
				adView.setBackgroundColor(Color.TRANSPARENT);
				adView.setAdSize(size);
				adView.setAdUnitId(mPublishID);
				AdRequest.Builder builder = new AdRequest.Builder();

				try {
					if (mTestDevices != null) {
						Iterator<String> ir = mTestDevices.iterator();
						while (ir.hasNext()) {
							builder.addTestDevice(ir.next());
						}
					}
				} catch (Exception e) {
					LogE("Error during add test device", e);
				}

				adView.loadAd(builder.build());
				adView.setAdListener(new AdmobAdsListener());

				if (null == mWm) {
					mWm = (WindowManager) mContext.getSystemService("window");
				}
				AdsWrapper.addAdView(mWm, adView, curPos);
			}
		});
	}

	private void hideBannerAd() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (null != adView) {
					if (null != mWm) {
						mWm.removeView(adView);
					}
					adView.destroy();
					adView = null;
				}
			}
		});
	}

	public void addTestDevice(String deviceID) {
		LogD("addTestDevice invoked : " + deviceID);
		if (null == mTestDevices) {
			mTestDevices = new HashSet<String>();
		}
		mTestDevices.add(deviceID);
	}
	
	public void loadInterstitial() {
		interstitialAdView = new InterstitialAd(mContext);
		interstitialAdView.setAdUnitId(mPublishID);
		interstitialAdView.setAdListener(new AdmobAdsListener());

		AdRequest.Builder builder = new AdRequest.Builder();
		try {
			if (mTestDevices != null) {
				Iterator<String> ir = mTestDevices.iterator();
				while(ir.hasNext())
				{
					builder.addTestDevice(ir.next());
				}
			}
		} catch (Exception e) {
			LogE("Error during add test device", e);
		}

		//begin load interstitial ad
		interstitialAdView.loadAd(builder.build());
	}
	
	public void showInterstitial() {
		if (interstitialAdView == null || interstitialAdView.isLoaded() == false) {
			Log.e("PluginAdmob", "ADMOB: Interstitial cannot show. It is not ready");
		} else {
			interstitialAdView.show();
		}
	}
	
	private class AdmobAdsListener extends AdListener {
		@Override
		public void onAdClosed() {
			super.onAdClosed();
			
			LogD("onDismissScreen invoked");
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Ads view dismissed!");
		}

		@Override
		public void onAdFailedToLoad(int errorCode) {
			super.onAdFailedToLoad(errorCode);
			
			int errorNo = AdsWrapper.RESULT_CODE_UnknownError;
			String errorMsg = "Unknow error";
			switch (errorCode) {
			case AdRequest.ERROR_CODE_NETWORK_ERROR:
				errorNo =  AdsWrapper.RESULT_CODE_NetworkError;
				errorMsg = "Network error";
				break;
			case AdRequest.ERROR_CODE_INVALID_REQUEST:
				errorNo = AdsWrapper.RESULT_CODE_NetworkError;
				errorMsg = "The ad request is invalid";
				break;
			case AdRequest.ERROR_CODE_NO_FILL:
				errorMsg = "The ad request is successful, but no ad was returned due to lack of ad inventory.";
				break;
			default:
				break;
			}
			LogD("failed to receive ad : " + errorNo + " , " + errorMsg);
			AdsWrapper.onAdsResult(mAdapter, errorNo, errorMsg);
		}
		
		@Override
		public void onAdLeftApplication() {
			super.onAdLeftApplication();
			LogD("onLeaveApplication invoked");
		}
		
		@Override
		public void onAdOpened() {
			LogD("onPresentScreen invoked");
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsShown, "Ads view shown!");
			
			super.onAdOpened();
		}

		@Override
		public void onAdLoaded() {
			LogD("onReceiveAd invoked");
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsReceived, "Ads request received success!");
			
			super.onAdLoaded();
		}
	}

	@Override
	public String getPluginVersion() {
		return "0.2.0";
	}

    @Override
    public void queryPoints() {
        LogD("Admob not support query points!");
    }
    
    public boolean hasInterstitial() {
    	return interstitialAdView.isLoaded();
    }
    
    public void setBannerAnimationInfo(Hashtable<Integer, Integer> devInfo) {
    	slideUpTimePeriod = devInfo.get("slideUpTimePeriod");
    	slideDownTimePeriod = devInfo.get("slideDownTimePeriod");
    }
    
    public void slideUpBannerAds() {
//    	mContext.runOnUiThread(new Runnable() {
//
//			@Override
//			public void run() {
//				adView.setVisibility(View.VISIBLE);
//				MyUtils myUtils = new MyUtils();
//				myUtils.SlideUp(adView, mContext);
//			}
//		});
//
//    	Executors.newSingleThreadScheduledExecutor().schedule(new Runnable() {
//
//			@Override
//			public void run() {
//				slideDownBannerAds();
//			}
//		}, slideUpTimePeriod, TimeUnit.SECONDS);
    }
    
    public void slideDownBannerAds() {
//    	mContext.runOnUiThread(new Runnable() {
//
//			@Override
//			public void run() {
//				MyUtils myUtils = new MyUtils();
//				myUtils.SlideDown(adView, mContext);
//			}
//		});
//
//    	Executors.newSingleThreadScheduledExecutor().schedule(new Runnable() {
//
//			@Override
//			public void run() {
//				slideUpBannerAds();
//			}
//		}, slideDownTimePeriod, TimeUnit.SECONDS);
    }
        
    public class MyUtils {

        public void SlideUp(final View view, Context context) {
            Animation anim = AnimationUtils.loadAnimation(context, R.anim.slide_down);
            anim.setAnimationListener(new Animation.AnimationListener() {

                @Override
                public void onAnimationStart(Animation animation) {
                    // TODO Auto-generated method stub
                    view.setAlpha(255);
                    view.setVisibility(View.VISIBLE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    // TODO Auto-generated method stub

                }
            });
            view.startAnimation(anim);


        }

        public void SlideDown(final View view, Context context) {
            Animation anim = AnimationUtils.loadAnimation(context, R.anim.slide_up);
            anim.setAnimationListener(new Animation.AnimationListener() {

                @Override
                public void onAnimationStart(Animation animation) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void onAnimationRepeat(Animation animation) {
                    // TODO Auto-generated method stub

                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    // TODO Auto-generated method stub
                    view.setVisibility(View.INVISIBLE);
                }
            });
            view.startAnimation(anim);

        }
    }
}
