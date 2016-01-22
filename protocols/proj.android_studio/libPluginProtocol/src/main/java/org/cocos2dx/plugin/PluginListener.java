package org.cocos2dx.plugin;

import android.content.Intent;

public interface PluginListener {
	public void onStart();
	public void onResume();
	public void onPause();
	public void onStop();
	public void onDestroy();
	public void onBackPressed();
	public boolean onActivityResult(int requestCode, int resultCode, Intent data);
}
