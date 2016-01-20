package org.cocos2dx.plugin;

import java.util.Hashtable;

public interface InterfaceData {
	public final int PluginType = 7;
	
	public void configDeveloperInfo(Hashtable<String, String> devInfo);
	public void openData(String fileName, int dataConflictPolicy);
	public void readCurrentData();
	public void resolveConflict(String conflictId, byte[] data, Hashtable<String, String> changes);
	public void commitData(byte[] data, String imagePath, String description);
}
