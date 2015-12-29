/**
 * Created by tuan on 12/28/15.
 */
package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.baasbox.android.BaasBox;
import com.baasbox.android.BaasException;
import com.baasbox.android.BaasHandler;
import com.baasbox.android.BaasResult;
import com.baasbox.android.BaasUser;
import com.baasbox.android.json.JsonArray;
import com.baasbox.android.json.JsonObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Hashtable;

public class BaaSBaasbox implements InterfaceBaaS {
    public static final int RESULT_CODE_LoginSucceed 		= 0;
    public static final int RESULT_CODE_LoginFailed 		= 1;
    public static final int RESULT_CODE_LogoutSucceed 		= 2;
    public static final int RESULT_CODE_LogoutFailed		= 3;
    public static final int RESULT_CODE_SignUpSucceed 		= 4;
    public static final int RESULT_CODE_SignUpFailed 		= 5;
    public static final int RESULT_CODE_SaveSucceed 		= 6;
    public static final int RESULT_CODE_SaveFailed 			= 7;
    public static final int RESULT_CODE_RetrieveSucceed 	= 8;
    public static final int RESULT_CODE_RetrieveFailed 		= 9;
    public static final int RESULT_CODE_DeleteSucceed 		= 10;
    public static final int RESULT_CODE_DeleteFailed 		= 11;
    public static final int RESULT_CODE_UpdateSucceed 		= 12;
    public static final int RESULT_CODE_UpdateFailed 		= 13;
    public static final int RESULT_CODE_FetchConfigSucceed	= 14;
    public static final int RESULT_CODE_FetchConfigFailed 	= 15;

    private static final String TAG = "BaaSBaasbox";
    private static Activity mContext 	= null;
    private static BaaSBaasbox mAdapter 	= null;
    private BaasBox client;


    public void logD(String msg) {
            Log.d(TAG, msg);
    }

    public BaaSBaasbox(Context context) {
        mContext = (Activity) context;
        mAdapter = this;
    }

    @Override
    public void configDeveloperInfo(Hashtable<String, String> devInfo) {
        String baseURL  = devInfo.get("baseURL");
        String appCode  = devInfo.get("appCode");
        String senderId = devInfo.get("senderId");

        BaasBox.Builder b = new BaasBox.Builder(mContext);
        client = b.setApiDomain(baseURL)
                .setAppCode(appCode)
				.setSenderId(senderId)
				.init();
    }

    @Override
    public void signUp(Hashtable<String, String> userInfo, int callbackID) {

    }

    @Override
    public void login(String userName, String password, int callbackID) {
        final long cbID = callbackID;
        BaasUser user = BaasUser.withUserName(userName)
                .setPassword(password);
        user.login(new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> result) {
                if (result.isSuccess()) {
                    Log.d("LOG", "The user is currently logged in: " + result.value());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LoginSucceed, result.value().toString(), cbID);
                } else {
                    Log.e("LOG", "Show error", result.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LoginFailed, makeErrorJsonString(result.error()), cbID);
                }
            }
        });
    }

    @Override
    public void logout(int callbackID) {
        final long cbID = callbackID;
        BaasUser.current().logout(new BaasHandler<Void>() {
            @Override
            public void handle(BaasResult<Void> result) {
                if (result.isSuccess()) {
                    Log.d(TAG, "Logged out: " + (BaasUser.current() == null));
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LogoutSucceed,"Disconnected to Baasbox ",cbID);
                } else {
                    Log.e(TAG, "Logout error", result.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LogoutFailed, makeErrorJsonString(result.error()), cbID);
                }
            }
        });
    }

    @Override
    public boolean isLoggedIn() {
        return BaasUser.current() != null;
    }

    private static void JsonObjectPutObject(JsonObject obj,String key,Object value){
        if(value == null) {
            obj.putNull(key);
        } else if(value instanceof JsonArray) {
            obj.put(key, ((JsonArray) value).copy());
        } else if(value instanceof JsonObject) {
            obj.put(key, ((JsonObject) value).copy());
        } else if(value instanceof Long){
            obj.put(key,(long) value);
        } else if(value instanceof Boolean){
            obj.put(key,(boolean) value);
        }else if(value instanceof Double){
            obj.put(key,(double) value);
        }else if(value instanceof String){
            obj.put(key,(String) value);
        }else if(value instanceof byte[]) {
            byte[] original = (byte[])value;
            byte[] copy = new byte[original.length];
            System.arraycopy(original, 0, copy, 0, original.length);
            obj.put(key, copy);
        }
    }

    public static String makeErrorJsonString(BaasException e) {
        if (e != null) {
            try {

                JSONObject json = new JSONObject();
                json.accumulate("description", e.getMessage());

                return json.toString();

            } catch (JSONException ex) {
                Log.i(TAG, "Error when making json.");
            }
        }

        return null;
    }


    //DELETE

    @Override
    public void saveObjectInBackground(String className, String json, int callbackID) {

    }

    @Override
    public String saveObject(String className, String json) {
        return null;
    }

    @Override
    public void findObjectInBackground(String className, String whereKey, String equalTo, int callbackID) {

    }

    @Override
    public void getObjectInBackground(String className, String objId, int callbackID) {

    }

    @Override
    public String getObject(String className, String objId) {
        return null;
    }

    @Override
    public void updateObjectInBackground(String className, String objId,
                                         final String jsonChanges, int callbackID) {
    }

    @Override
    public String updateObject(String className, String objId,
                               String jsonChanges) {
        return null;
    }

    @Override
    public void deleteObjectInBackground(String className, String objId, int callbackID) {
    }

    @Override
    public String deleteObject(String className, String objId) {
        return "";
    }

    @Override
    public void fetchConfigInBackground(int callbackID) {

    }

    @Override
    public boolean getBoolConfig(String param) {
        return false;
    }

    @Override
    public int getIntegerConfig(String param) {
        return 0;
    }

    @Override
    public double getDoubleConfig(String param) {
        return 0.0;
    }

    @Override
    public long getLongConfig(String param) {
        return 0;
    }

    @Override
    public String getStringConfig(String param) {
       return "";
    }

    @Override
    public String getArrayConfig(String param) {
        return "";
    }
}


