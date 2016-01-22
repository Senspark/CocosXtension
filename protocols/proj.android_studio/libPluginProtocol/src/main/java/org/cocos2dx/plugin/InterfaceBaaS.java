package org.cocos2dx.plugin;

import java.util.Hashtable;

public interface InterfaceBaaS {
	public final int PluginType = 8;
	
    public void configDeveloperInfo(Hashtable<String, String> devInfo);
    public void signUp(Hashtable<String, String> userInfo, int cbID);
    public void login(String userName, String password, int cbID);
    public void logout(int cbID);
    public boolean isLoggedIn();
    public String getUserID();
    public void saveObjectInBackground(String className, String json, int cbID);
    public String saveObject(String className, String json);
  
    public void getObjectInBackground(String className, String objId, int cbID);
    public void getObjectsInBackground(String className, String objIds, int cbID);
    public String getObject(String className, String objId);
    
    public void findObjectInBackground(String className, String whereKey, String equalTo, int cbID);
    public void findObjectsInBackground(String className, String whereKey, String containInArray, int cbID);
    
    public void updateObjectInBackground(String className, String objId, String jsonChanges, int cbID);
    public String updateObject(String className, String objId, String jsonChanges);
    
    public void deleteObjectInBackground(String className, String objId, int cbID);
    public String deleteObject(String className, String objId);
    
}
