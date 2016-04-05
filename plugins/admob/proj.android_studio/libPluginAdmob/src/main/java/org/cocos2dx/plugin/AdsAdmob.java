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
import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;

import com.android.vending.billing.IInAppBillingService;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.purchase.InAppPurchaseResult;
import com.google.android.gms.ads.purchase.PlayStorePurchaseListener;

import java.util.Collections;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

public class AdsAdmob implements InterfaceAds, PlayStorePurchaseListener {

	private static final String LOG_TAG = "AdsAdmob";
	private static Activity mContext = null;
	private static boolean bDebug = true;
	private static AdsAdmob mAdapter = null;

	private AdView adView = null;
	private InterstitialAd interstitialAdView = null;
	private boolean isLoaded = false;

	private String mPublishID = "";
	private Set<String> mTestDevices = null;

	private String pAppPublicKey = null;

	private static final int ADMOB_SIZE_BANNER = 1;
	private static final int ADMOB_SIZE_SMART_BANNER = 2;
	private static final int ADMOB_SIZE_LARGE_BANNER = 3;
	private static final int ADMOB_SIZE_LEADERBOARD = 4;
	private static final int ADMOB_SIZE_MEDIUM_RECTANGLE = 5;
	private static final int ADMOB_SIZE_WIDE_SKYSCRAPER = 6;
	private static final int ADMOB_SIZE_FULL_BANNER = 7;

	private static final int ADMOB_TYPE_BANNER = 1;
	private static final int ADMOB_TYPE_FULLSCREEN = 2;

	private volatile boolean mShouldLock = false;

	public static final int BILLING_RESPONSE_RESULT_OK = 0;
	private IInAppBillingService mService;

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
		Log.i(LOG_TAG, "Initializing AdsAdmob");
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
		LogD("configDeveloperInfo");
		try {
			mPublishID = devInfo.get("AdmobID");
			LogD("id interstitialAd : " + mPublishID);
			pAppPublicKey = devInfo.get("AppPublicKey");
		} catch (Exception e) {
			LogE("initAppInfo, The format of appInfo is wrong", e);
		}
	}

	@Override
	public void showAds(Hashtable<String, String> info, int pos) {
	    try {
	        String strType = info.get("AdmobType");
	        int adsType = Integer.parseInt(strType);

	        switch (adsType) {
	        case ADMOB_TYPE_BANNER: {
                String strSize = info.get("AdmobSizeEnum");
                int sizeEnum = Integer.parseInt(strSize);
                showBannerAd(sizeEnum, pos);
                break;
            }
	        case ADMOB_TYPE_FULLSCREEN: {
                showInterstitial();
                break;
            }
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
	    try {
            String strType = info.get("AdmobType");
            int adsType = Integer.parseInt(strType);

            switch (adsType) {
            case ADMOB_TYPE_BANNER: {
                hideBannerAd();
                break;
            }
            case ADMOB_TYPE_FULLSCREEN: {
                LogD("Now not support full screen view in Admob");
                break;
            }
            default:
                break;
            }
        } catch (Exception e) {
            LogE("Error when hide Ads ( " + info.toString() + " )", e);
        }
	}

	private synchronized void showBannerAd(final int sizeEnum, final int pos) {
		mShouldLock = true;
		PluginWrapper.runOnMainThread(new Runnable() {

			@Override
			public void run() {
				AdSize size = AdSize.BANNER;
				switch (sizeEnum) {
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

				adView = new AdView(mContext);
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
				adView.setAdListener(new AdmobAdsBannerListener());

				AdsWrapper.addAdView(adView, pos);

				Log.i(LOG_TAG, "Show Ad: waiting for adView: DONE");

				synchronized (AdsAdmob.this) {
					mShouldLock = false;
					AdsAdmob.this.notify();
				}
			}
		});

		Log.i(LOG_TAG, "Show Ad: waiting for adView");

		synchronized (this) {
			try {
				if (mShouldLock) {
					wait();
				}
			} catch (InterruptedException ex) {
				ex.printStackTrace();
			}
		}

		Log.i(LOG_TAG, "Show Ad: stop waiting for adView");

	}

	private void hideBannerAd() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (null != adView) {
					adView.setVisibility(View.GONE);
					adView.destroy();
					adView = null;
				}
			}
		});
	}

	public void addTestDevice(final String deviceID) {
		mContext.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				LogD("addTestDevice invoked : " + deviceID);
				if (null == mTestDevices) {
					mTestDevices = new HashSet<>();
				}
				mTestDevices.add(deviceID);
			}
		});

	}

	public void loadInterstitial() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				Log.i(LOG_TAG, "Start loading interstitial ad");
				interstitialAdView = new InterstitialAd(mContext);
				interstitialAdView.setPlayStorePurchaseParams(mAdapter, pAppPublicKey);
				interstitialAdView.setAdUnitId(mPublishID);
				interstitialAdView.setAdListener(new AdmobAdsInterstitialListener());

				AdRequest.Builder builder = new AdRequest.Builder();
				try {
					if (mTestDevices != null) {
                        for (String mTestDevice : mTestDevices) {
                            builder.addTestDevice(mTestDevice);
                        }
					}
				} catch (Exception e) {
					LogE("Error during add test device", e);
				}

				//begin load interstitial ad
				interstitialAdView.loadAd(builder.build());
			}
		});
	}
	
	public void showInterstitial() {
		mContext.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if (interstitialAdView == null || interstitialAdView.isLoaded() == false) {
					Log.e("PluginAdmob", String.format("ADMOB: Interstitial cannot show. It is not ready: - InterstitialAdView: %s - isLoaded: %b",
                        interstitialAdView == null ? "null" : interstitialAdView.toString(),
                        interstitialAdView != null && interstitialAdView.isLoaded()));
					loadInterstitial();
				} else {
					interstitialAdView.show();
				}
			}
		});
	}

	public int getBannerWidthInPixel() {
		int ret = 0;
		if (adView != null && mContext != null) {
			ret = adView.getAdSize().getWidthInPixels(mContext);
		}
		return ret;
	}

	public int getBannerHeightInPixel() {
		int ret = 0;
		if (adView != null && mContext != null) {
			ret = adView.getAdSize().getHeightInPixels(mContext);
		}
		return ret;
	}
	
	private class AdmobAdsBannerListener extends AdListener {
		@Override
		public void onAdClosed() {
			super.onAdClosed();
			loadInterstitial();
			LogD("onDismissScreen invoked");
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Ads view dismissed!");
		}

		@Override
		public void onAdFailedToLoad(int errorCode) {
			Log.e(LOG_TAG,"load interstitial failed error code "+ errorCode);
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
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsBannerReceived, "Ads request received success!");

			if (adView != null) {
				adView.setVisibility(View.GONE);
				adView.setVisibility(View.VISIBLE);

				if (adView.getAdSize().isAutoHeight()) {
					Log.i(LOG_TAG, "AdSize is SMART BANNER. Set its background color BLACK");
					adView.setBackgroundColor(Color.BLACK);
				}
			}

			super.onAdLoaded();
		}
	}

	private class AdmobAdsInterstitialListener extends AdListener {
		@Override
		public void onAdClosed() {
			super.onAdClosed();
			loadInterstitial();
			LogD("onDismissScreen invoked");
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsDismissed, "Ads view dismissed!");
		}

		@Override
		public void onAdFailedToLoad(int errorCode) {
			Log.e(LOG_TAG,"load interstitial failed error code "+ errorCode);
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
			AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsInterstitialReceived, "Ads request received success!");

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
    
    public synchronized boolean hasInterstitial() {
		isLoaded = false;
		mShouldLock = true;

		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				isLoaded = interstitialAdView.isLoaded();

				synchronized (AdsAdmob.this) {
					mShouldLock = false;
					AdsAdmob.this.notify();
				}
			}
		});

		synchronized (this) {
			try {
				if (mShouldLock) {
					wait();
				}
			} catch (InterruptedException ex) {
				ex.printStackTrace();
			}
		}

    	return isLoaded;
    }

	public void slideBannerUp() {
		Log.i(LOG_TAG, "Slide Banner Up: CALL");

		if (adView == null) {
			Log.i(LOG_TAG, "Slide Banner Up: NO VIEW");
		}

		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (adView != null) {
					adView.setVisibility(View.INVISIBLE);
					TranslateAnimation anim = new TranslateAnimation(Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 1, Animation.RELATIVE_TO_PARENT, 0);
					anim.setDuration(1000);
					anim.setFillAfter(true);

					anim.setAnimationListener(new Animation.AnimationListener() {
						@Override
						public void onAnimationStart(Animation animation) {
							Log.i(LOG_TAG, "Slide Banner Up: START");
							if (adView != null) {
								adView.setVisibility(View.VISIBLE);
							}
						}

						@Override
						public void onAnimationEnd(Animation animation) {
							Log.i(LOG_TAG, "Slide Banner Up: END");
						}

						@Override
						public void onAnimationRepeat(Animation animation) {
						}
					});
					adView.startAnimation(anim);
				}
			}
		});
	}

	public void slideBannerDown() {
		Log.i(LOG_TAG, "Slide Banner Down: CALL");

		if (adView == null) {
			Log.i(LOG_TAG, "Slide Banner Down: NO VIEW");
			return;
		}

		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (adView != null) {
					adView.setVisibility(View.VISIBLE);
					TranslateAnimation anim = new TranslateAnimation(Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 0, Animation.RELATIVE_TO_PARENT, 1);
					anim.setDuration(1000);
					anim.setFillAfter(true);

					anim.setAnimationListener(new Animation.AnimationListener() {
						@Override
						public void onAnimationStart(Animation animation) {
							Log.i(LOG_TAG, "Slide Banner Down: START");
						}

						@Override
						public void onAnimationEnd(Animation animation) {
							Log.i(LOG_TAG, "Slide Banner Down: END");
							adView.setVisibility(View.GONE);
						}

						@Override
						public void onAnimationRepeat(Animation animation) {
						}
					});

					adView.startAnimation(anim);
				}
			}
		});
	}

	@Override
	public boolean isValidPurchase(String sku) {
		// Optional: check if the product has already been purchased.
		try {
			if (getOwnedProducts().contains(sku)) {
				// Handle the case if product is already purchased.
				return false;
			}
		} catch (RemoteException e) {
			Log.e("Iap-Ad", "Query purchased product failed.", e);
			return false;
		}
		return true;
	}

	@Override
	public void onInAppPurchaseFinished(InAppPurchaseResult result) {
		Log.i("Iap-Ad", "onInAppPurchaseFinished Start");
		int resultCode = result.getResultCode();
		Log.i("Iap-Ad", "result code: " + resultCode);
		String sku = result.getProductId();
		if (resultCode == Activity.RESULT_OK) {
			Log.i("Iap-Ad", "purchased product id: " + sku);
			int responseCode = result.getPurchaseData().getIntExtra(
					"RESPONSE_CODE", BILLING_RESPONSE_RESULT_OK);
			String purchaseData = result.getPurchaseData().getStringExtra("INAPP_PURCHASE_DATA");
			Log.i("Iap-Ad", "response code: " + responseCode);
			Log.i("Iap-Ad", "purchase data: " + purchaseData);

			// Finish purchase and consume product.
			result.finishPurchase();
			// if (responseCode == BILLING_RESPONSE_RESULT_OK) {
			// Optional: your custom process goes here, e.g., add coins after purchase.
			//  }
		} else {
			Log.w("Iap-Ad", "Failed to purchase product: " + sku);
		}
		Log.i("Iap-Ad", "onInAppPurchaseFinished End");
	}

	private List<String> getOwnedProducts() throws RemoteException {
		// Query for purchased items.
		// See http://developer.android.com/google/play/billing/billing_reference.html and
		// http://developer.android.com/google/play/billing/billing_integrate.html
		Bundle ownedItems = mService.getPurchases(3, mContext.getApplicationContext().getPackageName(), "inapp", null);
		int response = ownedItems.getInt("RESPONSE_CODE");
		Log.i("Iap-Ad", "Response code of purchased item query");
		if (response == 0) {
			return ownedItems.getStringArrayList("INAPP_PURCHASE_ITEM_LIST");
		}
		return Collections.emptyList();
	}
}
