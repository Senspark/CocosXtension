package org.cocos2dx.plugin;

import java.util.Hashtable;

public interface InterfaceBaaS {
	public final int PluginType = 8;
	
    public void configDeveloperInfo(Hashtable<String, String> devInfo);
    public void signUp(Hashtable<String, String> userInfo);
    public void login(String userName, String password);
    public void logout();
    public boolean isLoggedIn();
    public void saveObjectInBackground(String className, String json);
    public String saveObject(String className, String json);
    public void getObjectInBackground(String className, String objId);
    public String getObject(String className, String objId);
    public void updateObjectInBackground(String className, String objId, String jsonChanges);
    public String updateObject(String className, String objId, String jsonChanges);
}
