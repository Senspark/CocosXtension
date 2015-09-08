package org.cocos2dx.plugin;

import java.lang.Thread.UncaughtExceptionHandler;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

import android.content.Context;
import android.util.Log;

import com.google.android.gms.analytics.ExceptionReporter;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.HitBuilders;
import com.google.android.gms.analytics.Tracker;

public class AnalyticsGoogle implements InterfaceAnalytics {
	protected static final String LOG_TAG = "AnalyticsGoogle";
	protected Context mContext = null;
	protected static boolean isDebug = false;
	protected GoogleAnalytics mGoogleAnalytics = null;
	protected Tracker tracker = null;
	protected boolean mCrashUncaughtEnable = false;

	protected Map<String, Tracker> mTrackers = null;

	public AnalyticsGoogle(Context context) {
		mTrackers = new HashMap<String, Tracker>();
		mContext = context;
		mGoogleAnalytics = GoogleAnalytics.getInstance(context);
	}

	public void configureTracker(String trackerId) {
		if (null == trackerId) {
			Log.d(LOG_TAG, "Null tracker id at configure time.");
			return;
		}

		Log.d(LOG_TAG, "Configure with trackerId: " + trackerId);

		createTracker(trackerId);
	}

	public void createTracker(String trackerId) {
		Tracker tr = (Tracker) this.mTrackers.get(trackerId);
		if (null == tr) {
			tr = this.mGoogleAnalytics.newTracker(trackerId);

			if (this.mTrackers.size() == 0) {
				tr.setScreenName(this.mContext.getClass().getCanonicalName());
			}

			this.mTrackers.put(trackerId, tr);
		}

		enableTracker(trackerId);
	}

	public void enableTracker(String trackerId) {
		if (null == trackerId) {
			return;
		}

		Tracker tr = (Tracker) this.mTrackers.get(trackerId);
		if (null == tr) {
			Log.d(LOG_TAG, "Trying to enable unknown tracker: " + trackerId);
		} else {
			Log.d(LOG_TAG, "Selected tracker: " + trackerId);
			this.tracker = tr;
		}
	}

	public void setLogLevel(int logLevel) {
		mGoogleAnalytics.getLogger().setLogLevel(logLevel);
	}

	public void dispatchHits() {
		mGoogleAnalytics.dispatchLocalHits();
	}

	public void dispatchPeriodically(int numberOfSeconds) {
		mGoogleAnalytics.setLocalDispatchPeriod(numberOfSeconds);
	}

	public void stopPeriodicalDispatch() {
		mGoogleAnalytics.setLocalDispatchPeriod(-1);
	}

	@Override
	public void startSession(String appKey) {
		if (this.tracker != null) {
			this.tracker.setScreenName(appKey);
			this.tracker.send(new HitBuilders.ScreenViewBuilder()
					.setNewSession().build());
		} else
			Log.e(LOG_TAG, "Start session called w/o valid tracker.");
	}

	@Override
	public void stopSession() {
		if (this.tracker != null) {
			this.tracker.send((new HitBuilders.ScreenViewBuilder().set("&sc",
					"end")).build());
		} else
			Log.e(LOG_TAG, "Start session called w/o valid tracker.");
	}

	public void trackScreen(String screenName) {
		if (null != this.tracker) {
			this.tracker.setScreenName(screenName);
			this.tracker.send(new HitBuilders.ScreenViewBuilder().build());
		} else {
			Log.e(LOG_TAG, "Log Screen called w/o valid tracker.");
		}
	}

	public void trackEvent(String category, String action, String label,
			int value) {
		if (null != this.tracker) {
			this.tracker.send(new HitBuilders.EventBuilder()
					.setCategory(category).setAction(action).setLabel(label)
					.setValue(value).build());
		} else
			Log.e(LOG_TAG, "Log Event called w/o valid tracker.");
	}

	// public void trackEvent(Hashtable<String, String> params) {
	//
	// }

	public void trackException(String description, boolean fatal) {
		if (null != this.tracker) {
			this.tracker.send(new HitBuilders.ExceptionBuilder()
					.setDescription(description).setFatal(fatal).build());
		} else
			Log.e(LOG_TAG, "Log Exception called w/o valid tracker.");
	}

	// public void trackException(Hashtable<String, String> params) {
	//
	// }

	public void trackTimming(String category, int interval, String name,
			String label) {
		if (null != this.tracker) {
			this.tracker.send(new HitBuilders.TimingBuilder()
					.setCategory(category).setValue(interval).setVariable(name)
					.setLabel(label).build());
		} else
			Log.e(LOG_TAG, "Log Timing called w/o valid tracker.");
	}

	// public void trackTiming(Hashtable<String, String> params) {
	//
	// }

	public void trackSocial(String network, String action, String target) {
		if (this.tracker != null)
			this.tracker.send(new HitBuilders.SocialBuilder()
					.setNetwork(network).setAction(action).setTarget(target)
					.build());
		else
			Log.e(LOG_TAG, "Log Social called w/o valid tracker.");
	}

	void setDryRun(boolean isDryRun) {
		mGoogleAnalytics.setDryRun(isDryRun);
	}

	void enableAdvertisingTracking(boolean enabled) {
		if (null != this.tracker)
			this.tracker.enableAdvertisingIdCollection(enabled);
		else
			Log.e(LOG_TAG, "Advertising called w/o valid tracker.");
	}

	@Override
	public void setSessionContinueMillis(int millis) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public void setCaptureUncaughtException(boolean isEnabled) {
		mCrashUncaughtEnable = isEnabled;
		
		if (isEnabled) {
			UncaughtExceptionHandler myHandler = new ExceptionReporter(tracker, Thread.getDefaultUncaughtExceptionHandler(), mContext); 
			Thread.setDefaultUncaughtExceptionHandler(myHandler);
		} else {
			Thread.setDefaultUncaughtExceptionHandler(null);
		}
	}

	@Override
	public void setDebugMode(boolean isDebugMode) {
		isDebug = isDebugMode;
		setDryRun(isDebug);
	}

	@Override
	public void logError(String errorId, String message) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public void logEvent(String eventId) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public void logEvent(String eventId, Hashtable<String, String> paramMap) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public void logTimedEventBegin(String eventId) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public void logTimedEventEnd(String eventId) {
		Log.i(LOG_TAG, "Not supported on Android");
	}

	@Override
	public String getSDKVersion() {
		return "7.5.71";
	}

	@Override
	public String getPluginVersion() {
		return "0.9.0";
	}

}