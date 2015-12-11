package org.cocos2dx.plugin;

import java.util.Hashtable;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks;
import com.google.android.gms.common.api.GoogleApiClient.OnConnectionFailedListener;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.plus.Plus;
import com.google.android.gms.plus.PlusShare;
import com.google.games.utils.GameHelper;

public class ShareGooglePlus implements InterfaceShare, PluginListener {
	protected static final String LOG_TAG = "ShareGooglePlus";
	
	protected Activity mContext;
	protected ShareGooglePlus mShareGooglePlus;
	protected GameHelper mGameHelper;
	protected boolean bDebug = true;

    private static final int RC_SHARE_G_PLUS = 8891;
	private static final int RESULT_OK = -1;
	
	protected void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}
		
	public ShareGooglePlus(Context context) {
		mContext = (Activity) context;
		mShareGooglePlus = this;
		PluginWrapper.addListener(this);
		mGameHelper = GooglePlayAgent.getInstance().getGameHelper();
	}
	
	@Override
	public void configDeveloperInfo(final Hashtable<String, String> cpInfo) {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
			}
		});
	}

	public String getUserId() {
		return "";
	}
	
	public String getAccessToken() {
		return "";
	}
	
	@Override
	public void setDebugMode(boolean debug) {
	}

	@Override
	public String getSDKVersion() {
		return "1.4.1";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

	@Override
	public void onStart() {
	}

	@Override
	public void onResume() {
	}

	@Override
	public void onPause() {
	}

	@Override
	public void onStop() {
	}

	@Override
	public void onDestroy() {
	}

	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		mGameHelper.onActivityResult(requestCode, resultCode, data);
        if (requestCode == RC_SHARE_G_PLUS) {
            if (resultCode == RESULT_OK) {
            	ShareWrapper.onShareResult(mShareGooglePlus, ShareWrapper.SHARERESULT_SUCCESS, "[Google+]: Share G+ succeeded.");
            } else {
            	ShareWrapper.onShareResult(mShareGooglePlus, ShareWrapper.SHARERESULT_FAIL, "[Google+]: Share G+ failed.");
            }
        }
		return true;
	}

	@Override
	public void shareToGooglePlus(int level, long score, String urlToShare, String prefillText, String contentDeepLinkId, String deepLinkId) {
		// TODO Auto-generated method stub
		PlusShare.Builder builder = new PlusShare.Builder(mContext);
        // Set call-to-action metadata.
        builder.addCallToAction(
                "Download", /* call-to-action button label */
                Uri.parse("http://www.senspark.com/url/gmci"), /* call-to-action url (for desktop use) */
                "/url/gmci" /* call to action deep-link ID (for mobile use), 512 characters or fewer */);

        // Set the content url (for desktop use).
        builder.setContentUrl(Uri.parse("http://www.senspark.com/url/gmci"));

        // Set the target deep-link ID (for mobile use).
        builder.setContentDeepLinkId("/url/gmci");

        // Set the share text.
        String text = "Wow! I just completed level " + level + " and had $" + score + ", try to beat that! Download this game";
        builder.setText(text);
        ((Activity) mContext).startActivityForResult(builder.getIntent(), RC_SHARE_G_PLUS);
	}

	@Override
	public void share(Hashtable<String, String> cpInfo) {
		// TODO Auto-generated method stub
		
	}
}
