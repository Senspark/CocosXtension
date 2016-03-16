package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

import java.security.MessageDigest;
import java.util.Locale;

public class ProtocolPlatform  {
	private static final int RC_UNUSED = 5001;
	protected ProtocolPlatform mAdapter = null;
	protected Context mContext = null;
	protected Activity mActivity = null;
	
	public ProtocolPlatform(Context context) {
		Log.i("ProtocolPlatform", "ProtocolPlatform constructor");
		mContext = context;
		mActivity = (Activity) context;
		mAdapter = this;
	}
	
	public boolean isAppInstalled(final String appName) {
		PackageManager pm = mContext.getPackageManager();
		boolean isInstalled;

		try {
			pm.getPackageInfo(appName, PackageManager.GET_ACTIVITIES);
			isInstalled = true;

		} catch (NameNotFoundException e) {
			isInstalled = false;
		}

		Log.i("ProtocolPlatform", "App " + appName + " is installed? - " + isInstalled);
		return isInstalled;
	}
	
	public boolean isRelease() {
		boolean isDebuggable =  ( 0 != ( mContext.getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE ) );
		return !isDebuggable;
	}
	
	public boolean isConnected(String hostName) {
		ConnectivityManager conMng = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = conMng.getActiveNetworkInfo();
		boolean isConnected = info != null && info.isConnectedOrConnecting();
		Log.i("ProtocolPlatform", "isConnected? - " + (isConnected? "YES" : "NO"));
		if (isConnected) {
			PlatformWrapper.onPlatformResult(PlatformWrapper.PLATFORM_RESULT_CODE_kConnected, "Network connected");
		} else {
			PlatformWrapper.onPlatformResult(PlatformWrapper.PLATFORM_RESULT_CODE_kUnconnected, "Network unconnected");
		}
		return isConnected;
	}
	
	public String getSHA1CertFingerprint() {
		PackageInfo info;
		try {
			info = mContext.getPackageManager().getPackageInfo(
					mContext.getPackageName(),
					PackageManager.GET_SIGNATURES);
			MessageDigest md;
			md = MessageDigest.getInstance("SHA1");
			md.update(info.signatures[0].toByteArray());
			String strResult = "";
			for (byte b : md.digest()) {
				strResult += Integer.toString(b & 0xff, 16);
			}
			strResult = strResult.toUpperCase(Locale.US);
			Log.d("hash key", "hash=" + strResult);
			return strResult;
		} catch (Exception e) {
			Log.e("name not found", e.toString());
			return "";
		}
	}
	
	public double getVersionCode() throws NameNotFoundException {
		return mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0).versionCode;
	}
	
	public void sendFeedback(final String appName) {
		final Intent emailIntent = new Intent(Intent.ACTION_SEND);
		emailIntent.setType("message/rfc822");
		emailIntent.putExtra(Intent.EXTRA_EMAIL, new String[] { "feedback@senspark.com" });

		emailIntent.putExtra(android.content.Intent.EXTRA_SUBJECT,
				"Feedbacks for " + appName);
		emailIntent
				.putExtra(
						android.content.Intent.EXTRA_TEXT,
						"I have feedbacks for "
								+ appName
								+ ":\n1.\n2.\n3.\n\nI accept to send the follow information to developers to improve the application.\n");
		mActivity.startActivityForResult(
				Intent.createChooser(emailIntent, "Send a feedback..."),
				RC_UNUSED);
	}
}
