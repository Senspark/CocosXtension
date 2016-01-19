/**
 * Created by tuan on 12/28/15.
 */
package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.baasbox.android.BaasBox;
import com.baasbox.android.BaasDocument;
import com.baasbox.android.BaasException;
import com.baasbox.android.BaasHandler;
import com.baasbox.android.BaasQuery;
import com.baasbox.android.BaasResult;
import com.baasbox.android.BaasUser;
import com.baasbox.android.json.JsonArray;
import com.baasbox.android.json.JsonObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

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
        String domain   = devInfo.get("domain");
        String port     = devInfo.get("port");
        String appCode  = devInfo.get("appCode");
        String senderId = devInfo.get("senderId");
        Log.d(TAG, "domain : " + domain + " port: " + port + " appcode: " + appCode + " senderId : " + senderId);
        BaasBox.Builder b = new BaasBox.Builder(mContext);
        client = b.setApiDomain(domain)
                .setPort(Integer.parseInt(port))
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
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LogoutSucceed, "Disconnected to Baasbox ", cbID);
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

    @Override
    public String getUserID(){
        return BaasUser.current().getName();
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

    public void loginWithFacebookToken(final String facebookToken, final int cbId){
        Log.i(TAG, "loginWithFacebookToken : " + facebookToken + " cbid: " + cbId);
        final long lCallbackId = cbId;
        BaasUser.signupWithProvider(BaasUser.Social.FACEBOOK, facebookToken, facebookToken, new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> baasResult) {
                if (baasResult.isSuccess()) {
                    BaasUser currentUser = baasResult.value();
                    Log.d(TAG, "get baasbox current user : " + currentUser.toString());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LoginSucceed, "login to baasbox successed ", lCallbackId);
                } else {
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_LoginFailed, makeErrorJsonString(baasResult.error()), lCallbackId);
                }
            }
        });

    }

    public void updateUserProfile(final String profile, final int cbId){
        Log.i(TAG,"updateProfile : "+profile+" cbid: "+cbId);
        final long lCallbackId = cbId;
        BaasUser user = BaasUser.current();

        JsonObject data = JsonObject.decode(profile);
        JsonObject visibleByRegisterUses   = data.get("visibleByRegisteredUsers");
        JsonObject visibleByTheUser        = data.get("visibleByTheUser");
        JsonObject visibleByAnonymousUsers = data.get("visibleByAnonymousUsers");
        JsonObject visibleByFriends        = data.get("visibleByFriends");

        Iterator v1 = visibleByRegisterUses.iterator();
        while (v1.hasNext()) {
            Map.Entry e = (Map.Entry) v1.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            JsonObjectPutObject(user.getScope(BaasUser.Scope.REGISTERED), key, value);
        }

        Iterator v2 = visibleByTheUser.iterator();
        while (v2.hasNext()) {
            Map.Entry e = (Map.Entry) v2.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            JsonObjectPutObject(user.getScope(BaasUser.Scope.PRIVATE), key, value);
        }

        Iterator v3 = visibleByAnonymousUsers.iterator();
        while (v3.hasNext()){
            Map.Entry e = (Map.Entry) v3.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            JsonObjectPutObject(user.getScope(BaasUser.Scope.PUBLIC), key, value);
        }

        Iterator v4 = visibleByFriends.iterator();
        while (v3.hasNext()){
            Map.Entry e = (Map.Entry) v4.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            JsonObjectPutObject(user.getScope(BaasUser.Scope.FRIEND), key, value);
        }

        user.save(new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> res) {
                if (res.isSuccess()) {
                    Log.d(TAG, "update user profile success");
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_SaveSucceed, "update profile BAAUser successed ", lCallbackId);
                } else {
                    Log.e(TAG, "update user profile fail : " + res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_SaveFailed, makeErrorJsonString(res.error()), lCallbackId);
                }
            }
        });

    }

    public void fetchUserProfile(final int cbId){
        Log.i(TAG, "fetchProfile  cbid: " + cbId);
        final long lCallbackId = cbId;
        BaasUser.fetch(BaasUser.current().getName(), new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> baasResult) {
                if (baasResult != null) {
                    BaasUser baasUser = baasResult.value();

                    JsonObject userInfo = new JsonObject();
                    userInfo.put("visibleByRegisteredUsers", baasUser.getScope(BaasUser.Scope.REGISTERED));
                    userInfo.put("visibleByTheUser",         baasUser.getScope(BaasUser.Scope.PRIVATE));
                    userInfo.put("visibleByAnonymousUsers",  baasUser.getScope(BaasUser.Scope.PUBLIC));
                    userInfo.put("visibleByFriends",         baasUser.getScope(BaasUser.Scope.FRIEND));

                    Log.i(TAG, "load visibleByRegister current user : " + userInfo);
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_RetrieveSucceed, userInfo.toString(), lCallbackId);
                } else {
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_RetrieveFailed, makeErrorJsonString(baasResult.error()), lCallbackId);
                }
            }
        });

    }

    public void loadUsersWithParameters(final String condition, final int cbId){
        Log.i(TAG,"floadUsersWithParameters cbid: "+cbId);
        final long lCallbackId = cbId;

        BaasQuery.Criteria filter = BaasQuery.builder()
                .where(condition)
                .criteria();
        BaasUser.fetchAll(filter, new BaasHandler<List<BaasUser>>() {
            @Override
            public void handle(BaasResult<List<BaasUser>> res) {
                if (res.isSuccess()) {
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_RetrieveSucceed, res.value().toString(), lCallbackId);
                } else {
                    Log.e(TAG, "fetch score user on baasbox error :" + res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, RESULT_CODE_RetrieveFailed, makeErrorJsonString(res.error()), lCallbackId);
                }
            }
        });

    }

    @Override
    public void saveObjectInBackground(String className, String json, int callbackID) {
        BaasDocument doc = new BaasDocument("test");
        doc.put("","");
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

}


