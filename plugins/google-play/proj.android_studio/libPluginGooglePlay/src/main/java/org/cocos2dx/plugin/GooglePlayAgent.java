package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;

import com.google.games.utils.GameHelper;

public class GooglePlayAgent {
	protected static GooglePlayAgent sInstance;
	
	public Context mContext;
	public GameHelper mGameHelper;
	
	public static GooglePlayAgent getInstance() {
		if (sInstance == null) {
			sInstance = new GooglePlayAgent();
		}
		return sInstance;
	}
	
	public void setup(Context context, int requestedClients) {
		mContext = context;
		mGameHelper = new GameHelper((Activity) context, requestedClients);
	}
	
	public GameHelper getGameHelper() {
		return mGameHelper;
	}
}
