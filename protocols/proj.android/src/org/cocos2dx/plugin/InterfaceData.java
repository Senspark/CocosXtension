package org.cocos2dx.plugin;

import java.util.Hashtable;

public interface InterfaceData {
	public void configDeveloperInfo(Hashtable<String, String> devInfo);
	public void openData(String fileName, int dataConflictPolicy);
	public void readCurrentData();
	public void resolveConflict(String conflictId, Byte[] data, Hashtable<String, String> changes);
	public void commitData(Byte[] data, String imagePath, String description);
}
