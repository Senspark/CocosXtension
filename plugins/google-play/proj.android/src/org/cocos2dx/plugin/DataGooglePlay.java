package org.cocos2dx.plugin;

import java.io.IOException;
import java.util.Hashtable;

import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.games.Games;
import com.google.android.gms.games.GamesStatusCodes;
import com.google.android.gms.games.snapshot.Snapshot;
import com.google.android.gms.games.snapshot.SnapshotMetadata;
import com.google.android.gms.games.snapshot.SnapshotMetadataChange;
import com.google.android.gms.games.snapshot.Snapshots;
import com.google.android.gms.games.snapshot.Snapshots.CommitSnapshotResult;
import com.google.games.utils.GameHelper;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

public class DataGooglePlay implements InterfaceData {
	private static final String LOG_TAG = "DataGooglePlay";
	private Activity mActivity = null;
	private DataGooglePlay mAdapter = null;
	private String mClientId = null;
	private Snapshots.OpenSnapshotResult mResult = null;
	private String mConflictId = null;
	private GameHelper mGameHelper = null;
	private long mLastOpen;
	
	public static final int RC_SAVED_GAMES = 9009;
	
	public static final int CONFLICT_POLICY_Manual = 0;
	public static final int CONFLICT_POLICY_LongestPlaytime = 1;
	public static final int CONFLICT_POLICY_LastKnowGood = 2;
	public static final int CONFLICT_POLICY_MostRecentlyModified = 3;
	public static final int CONFLICT_POLICY_Highest_Progress = 4;
	
	public static final int RESULT_CODE_OpenSucceed = 0;
	public static final int RESULT_CODE_OpenConflicting = 1;
	public static final int RESULT_CODE_OpenFailed = 2;
	public static final int RESULT_CODE_ResolveSucceed = 3;
	public static final int RESULT_CODE_ResolveFailed = 4;
	public static final int RESULT_CODE_ReadSucceed = 5;
	public static final int RESULT_CODE_ReadFailed = 6;
	public static final int RESULT_CODE_WriteSucceed = 7;
	public static final int RESULT_CODE_WriteFailed = 8;
	
	public DataGooglePlay(Activity activity, GameHelper helper) {
		mActivity = activity;
		mAdapter = this;
		mGameHelper = helper;
	}
	
	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
	}

	public void presentSnapshotList(String title, boolean allowAdd, boolean allowDelete, int maxSlots) {
		Intent savedGameIntent = Games.Snapshots.getSelectSnapshotIntent(mGameHelper.getApiClient(), title, allowAdd, allowDelete, maxSlots);
		mActivity.startActivityForResult(savedGameIntent, RC_SAVED_GAMES);
	}
	
	
	@Override
	public void openData(final String fileName, int dataConflictPolicy) {
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
	        @Override
	        protected Integer doInBackground(Void... params) {
	            // Open the saved game using its name.
	            Snapshots.OpenSnapshotResult result = Games.Snapshots.open(mGameHelper.getApiClient(),
	                    fileName, true).await();

	            if (result.getStatus().getStatusCode() == GamesStatusCodes.STATUS_OK) {
	            	mResult = result;
	            	mLastOpen = System.currentTimeMillis();
	            	//TODO: callback here
	            	Log.i(LOG_TAG, "Open successfully.");
	            } else if (result.getStatus().getStatusCode() == GamesStatusCodes.STATUS_SNAPSHOT_CONFLICT) {
	            	Log.i(LOG_TAG, "Conflict here.");
	            	
	            } else {
	            	Log.i(LOG_TAG, "Open error. " + result.getStatus().getStatusMessage());
	            }

	            return result.getStatus().getStatusCode();
	        }

	        @Override
	        protected void onPostExecute(Integer status) {
	            // Dismiss progress dialog and reflect the changes in the UI.
	            // ...
	        }
		};
		
		task.execute();
	}

	@Override
	public void readCurrentData() {
		
		if (mResult != null && mResult.getStatus().isSuccess() && mResult.getSnapshot().isDataValid()) {
			try {
				byte[] data = mResult.getSnapshot().getSnapshotContents().readFully();
				DataWrapper.onDataResult(this, RESULT_CODE_ReadSucceed, data);
				Log.i(LOG_TAG, "Read data succeed.");
			} catch (IOException ex) {
				DataWrapper.onDataResult(this, RESULT_CODE_ReadFailed, null);
				Log.i(LOG_TAG, "Read data failed.");
			}
		} else {
			DataWrapper.onDataResult(this, RESULT_CODE_ReadFailed, null);;
			Log.i(LOG_TAG, "Current snapshot is not available.");
		}
	}

	@Override
	public void resolveConflict(final String conflictId, final byte[] data,
			Hashtable<String, String> changes) {
		
		AsyncTask<Void, Void, Integer> task = new AsyncTask<Void, Void, Integer>() {
			@Override
			protected Integer doInBackground(Void... params) {

				Snapshot resolvedSnapshot = mResult.getSnapshot();
				
			    int status = mResult.getStatus().getStatusCode();
			    Log.i(LOG_TAG, "Save Result status: " + status);

			    if (status == GamesStatusCodes.STATUS_SNAPSHOT_CONFLICT) {
			    	resolvedSnapshot.getSnapshotContents().writeBytes(data);

			    	mResult = Games.Snapshots.resolveConflict(mGameHelper.getApiClient(), conflictId, resolvedSnapshot).await();
			    }
				
				return mResult.getStatus().getStatusCode();
			}
			
			@Override
			protected void onPostExecute(Integer result) {
				//TODO: call back here.
				if (result == GamesStatusCodes.STATUS_OK) {
					Log.i(LOG_TAG, "Resolve successful.");
					DataWrapper.onDataResult(mAdapter, RESULT_CODE_ResolveSucceed, null);
				} else {
					Log.i(LOG_TAG, "Resolve failed.");
					DataWrapper.onDataResult(mAdapter, RESULT_CODE_ResolveFailed, null);
				}
				
				super.onPostExecute(result);
			}
		};
		
		task.execute();
	}

	@Override
	public void commitData(final byte[] data, String imagePath, String description) {
		if (mResult == null || !mResult.getSnapshot().isDataValid()) {
			Log.i(LOG_TAG, "Error trying to commit a snapshot. You must always open it first");
			DataWrapper.onDataResult(mAdapter, RESULT_CODE_WriteFailed, null);
			return;
		}
	    
	    // Create a snapshot change to be committed with a description,
	    // cover image, and play time.
		SnapshotMetadataChange.Builder builder = new SnapshotMetadataChange.Builder();
		
		if (imagePath != null) {
			builder.setCoverImage(BitmapFactory.decodeFile(imagePath));
		}
		
		builder.setDescription(description);
	    
	    // Note: This is done for simplicity. You should record time since
	    // your game last opened a saved game.
		long millsSinceaPreviousSnapshotWasOpened = System.currentTimeMillis();
	    builder.setPlayedTimeMillis(mResult.getSnapshot().getMetadata().getPlayedTime() + millsSinceaPreviousSnapshotWasOpened);
	    
	    SnapshotMetadataChange changes = builder.build();
	    
	    mResult.getSnapshot().getSnapshotContents().writeBytes(data);
	    
	    PendingResult<Snapshots.CommitSnapshotResult> result = Games.Snapshots.commitAndClose(mGameHelper.getApiClient(), mResult.getSnapshot(), changes);
	    result.setResultCallback(new ResultCallback<Snapshots.CommitSnapshotResult>() {
			@Override
			public void onResult(CommitSnapshotResult result) {
				if (result.getStatus().isSuccess())
					DataWrapper.onDataResult(mAdapter, RESULT_CODE_WriteSucceed, data);
				else 
					DataWrapper.onDataResult(mAdapter, RESULT_CODE_WriteFailed, data);
			}
		});
		
	    mResult = null;
	}

}
