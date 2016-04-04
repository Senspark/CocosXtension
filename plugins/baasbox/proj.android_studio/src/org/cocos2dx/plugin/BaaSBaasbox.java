/**
 * Created by tuan on 12/28/15.
 */
package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.baasbox.android.BaasAsset;
import com.baasbox.android.BaasBox;
import com.baasbox.android.BaasDocument;
import com.baasbox.android.BaasException;
import com.baasbox.android.BaasHandler;
import com.baasbox.android.BaasQuery;
import com.baasbox.android.BaasQuery.Criteria;
import com.baasbox.android.BaasResult;
import com.baasbox.android.BaasUser;
import com.baasbox.android.SaveMode;
import com.baasbox.android.json.JsonArray;
import com.baasbox.android.json.JsonObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class BaaSBaasbox implements InterfaceBaaS {

    private static final String TAG = "BaaSBaasbox";
    private static Activity mContext 	= null;
    private static BaaSBaasbox mAdapter 	= null;
    private BaasBox client;


    public void logD(String msg) {
            Log.d(TAG, msg);
    }

    public BaaSBaasbox(Context context) {
        Log.d(TAG,"Baasbox contructor");
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
    public void signUp(Hashtable<String, String> userInfo, final int callbackID) {
        String username  = userInfo.get("username");
        String password  = userInfo.get("password");
        BaasUser user = BaasUser.withUserName(username)
                                .setPassword(password);

        user.signup(new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> result) {
                if (result.isSuccess()) {
                    Log.d(TAG, "Current user is: " + result.value());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, result.value().toString(), callbackID);
                } else {
                    Log.e(TAG, "Show error", result.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(result.error()), callbackID);
                }
            }
        });
    }

    @Override
    public void login(String userName, String password, int callbackID) {
        Log.d(TAG,"login with username : "+userName+" password : "+password);
        final long cbID = callbackID;
        BaasUser user = BaasUser.withUserName(userName)
                .setPassword(password);
        user.login(new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> result) {
                if (result.isSuccess()) {
                    Log.d(TAG, "The user is currently logged in: " + result.value());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, result.value().toString(), cbID);
                } else {
                    Log.e(TAG, "login error", result.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(result.error()), cbID);
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
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, "Disconnected to Baasbox ", cbID);
                } else {
                    Log.e(TAG, "Logout error", result.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(result.error()), cbID);
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
                Log.d(TAG, "Error when making json.");
            }
        }
        return null;
    }

    public void loginWithFacebookToken(final String facebookToken, final int cbId){
        Log.d(TAG, "loginWithFacebookToken : " + facebookToken + " cbid: " + cbId);
        final long lCallbackId = cbId;
        BaasUser.signupWithProvider(BaasUser.Social.FACEBOOK, facebookToken, facebookToken, new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> baasResult) {
                if (baasResult.isSuccess()) {
                    BaasUser currentUser = baasResult.value();
                    Log.d(TAG, "get baasbox current user : " + currentUser.toString());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, "login to baasbox successed ", lCallbackId);
                } else {
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(baasResult.error()), lCallbackId);
                }
            }
        });

    }

    public void updateUserProfile(final String profile, final int cbId){
        Log.d(TAG,"updateProfile : "+profile+" cbid: "+cbId);
        final long lCallbackId = cbId;
        BaasUser user = BaasUser.current();

        JsonObject data = JsonObject.decode(profile);
        JsonObject visibleByRegisterUses   = data.get("visibleByRegisteredUsers");
        JsonObject visibleByTheUser        = data.get("visibleByTheUser");
        JsonObject visibleByAnonymousUsers = data.get("visibleByAnonymousUsers");
        JsonObject visibleByFriends        = data.get("visibleByFriends");

        if(visibleByRegisterUses != null) {
            Iterator v1 = visibleByRegisterUses.iterator();
            while (v1.hasNext()) {
                Map.Entry e = (Map.Entry) v1.next();
                String key = (String) e.getKey();
                Object value = e.getValue();
                JsonObjectPutObject(user.getScope(BaasUser.Scope.REGISTERED), key, value);
            }
        }

        if(visibleByTheUser != null) {
            Iterator v2 = visibleByTheUser.iterator();
            while (v2.hasNext()) {
                Map.Entry e = (Map.Entry) v2.next();
                String key = (String) e.getKey();
                Object value = e.getValue();
                JsonObjectPutObject(user.getScope(BaasUser.Scope.PRIVATE), key, value);
            }
        }

        if(visibleByAnonymousUsers != null) {
            Iterator v3 = visibleByAnonymousUsers.iterator();
            while (v3.hasNext()) {
                Map.Entry e = (Map.Entry) v3.next();
                String key = (String) e.getKey();
                Object value = e.getValue();
                JsonObjectPutObject(user.getScope(BaasUser.Scope.PUBLIC), key, value);
            }
        }

        if(visibleByFriends != null) {
            Iterator v4 = visibleByFriends.iterator();
            while (v4.hasNext()) {
                Map.Entry e = (Map.Entry) v4.next();
                String key = (String) e.getKey();
                Object value = e.getValue();
                JsonObjectPutObject(user.getScope(BaasUser.Scope.FRIEND), key, value);
            }
        }

        user.save(new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> res) {
                if (res.isSuccess()) {
                    Log.d(TAG, "update user profile success");
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, "update profile BAAUser successed ", lCallbackId);
                } else {
                    Log.e(TAG, "update user profile fail : " + res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCallbackId);
                }
            }
        });

    }

    public void fetchUserProfile(final int cbId){
        Log.d(TAG, "fetchUserProfile  cbid: " + cbId);
        final long lCallbackId = cbId;
        BaasUser.fetch(BaasUser.current().getName(), new BaasHandler<BaasUser>() {
            @Override
            public void handle(BaasResult<BaasUser> baasResult) {
                if (baasResult != null) {
                    BaasUser baasUser = baasResult.value();

                    JsonObject userInfo = new JsonObject();
                    userInfo.put("visibleByRegisteredUsers", baasUser.getScope(BaasUser.Scope.REGISTERED));
                    userInfo.put("visibleByTheUser", baasUser.getScope(BaasUser.Scope.PRIVATE));
                    userInfo.put("visibleByAnonymousUsers", baasUser.getScope(BaasUser.Scope.PUBLIC));
                    userInfo.put("visibleByFriends", baasUser.getScope(BaasUser.Scope.FRIEND));

                    Log.d(TAG, "load visibleByRegister current user : " + userInfo);
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, userInfo.toString(), lCallbackId);
                } else {
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(baasResult.error()), lCallbackId);
                }
            }
        });
    }

    public void loadUsersWithParameters(final String condition, final int cbId){
        Log.d(TAG,"floadUsersWithParameters cbid: "+cbId);
        final long lCallbackId = cbId;

        BaasQuery.Criteria filter = BaasQuery.builder()
                .where(condition)
                .criteria();
        BaasUser.fetchAll(filter, new BaasHandler<List<BaasUser>>() {
            @Override
            public void handle(BaasResult<List<BaasUser>> res) {
                if (res.isSuccess()) {
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, res.value().toString(), lCallbackId);
                } else {
                    Log.e(TAG, "fetch score user on baasbox error :" + res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCallbackId);
                }
            }
        });
    }

    //baasbox object
    private static void BaasDocumentPutObject(BaasDocument doc,String key,Object value){
        if(value == null) {
            doc.putNull(key);
        } else if(value instanceof JsonArray) {
            doc.put(key, ((JsonArray) value).copy());
        } else if(value instanceof JsonObject) {
            doc.put(key, ((JsonObject) value).copy());
        } else if(value instanceof Long){
            doc.put(key,(long) value);
        } else if(value instanceof Boolean){
            doc.put(key,(boolean) value);
        }else if(value instanceof Double){
            doc.put(key,(double) value);
        }else if(value instanceof String){
            doc.put(key,(String) value);
        }else if(value instanceof byte[]) {
            byte[] original = (byte[])value;
            byte[] copy = new byte[original.length];
            System.arraycopy(original, 0, copy, 0, original.length);
            doc.put(key, copy);
        }
    }
    @Override
    public void saveObjectInBackground(String collectionName, String json, final int callbackID) {
        Log.d(TAG, "saveObjectInBackGround collectionName : " + collectionName + " data : " + json);
        BaasDocument doc = new BaasDocument(collectionName);
        JsonObject jsonObj = JsonObject.decode(json);
        Iterator v1 = jsonObj.iterator();
        while (v1.hasNext()) {
            Map.Entry e = (Map.Entry) v1.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            BaasDocumentPutObject(doc,key,value);
        }
        final long lCbId = (long)callbackID;
        doc.save(new BaasHandler<BaasDocument>() {
            @Override
            public void handle(BaasResult<BaasDocument> res) {
                if (res.isSuccess()) {
                    Log.d(TAG, "Saved object: " + res.value());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, res.value().toString(), lCbId);
                } else {
                    Log.d(TAG, "Saved object error ");
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCbId);
                }
            }
        });
    }

    @Override
    public String saveObject(String colectionName, String json) {
        return "Baasbox is not support";
    }

    @Override
    public void getObjectInBackground(String collectionName, String objId, int callbackID) {
        Log.d(TAG, "getObjectInBackground collectionName : " + collectionName + " objid : " + objId);
        final long lCbId = (long)callbackID;
        BaasDocument.fetch(collectionName, objId, new BaasHandler<BaasDocument>() {
            @Override
            public void handle(BaasResult<BaasDocument> baasResult) {
                if(baasResult.isSuccess()) {
                    BaasDocument d = baasResult.value();
                    Log.d(TAG,"Document to json: "+d.toJson());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, d.toJson().toString(), lCbId);
                } else {
                    Log.e(TAG,"error",baasResult.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, makeErrorJsonString(baasResult.error()), lCbId);
                }
            }
        });
    }

    @Override
    public void getObjectsInBackground(String colectionName, String stringJsonArrayId, int cbID){
        Log.d(TAG, "string array id " + stringJsonArrayId);

        final long lCbId = (long)cbID;

        JsonArray arrId = JsonArray.decode(stringJsonArrayId);

        BaasQuery.Builder builder = BaasQuery.builder()
                .pagination(0, 20)
                .orderBy("id")
                .where("id = " + "'" + arrId.getString(0) + "'");

        for (int i = 1; i < arrId.size(); i++) {
            builder.or("id = " + "'" + arrId.getString(i) + "'");
        }

        BaasQuery.Criteria filter = builder.criteria();

        BaasDocument.fetchAll(colectionName, filter, new BaasHandler<List<BaasDocument>>() {
            @Override
            public void handle(BaasResult<List<BaasDocument>> res) {
                if (res.isSuccess()) {
                    JsonArray arr = new JsonArray();
                    for (BaasDocument doc : res.value()) {
                        arr.add(doc.toJson());
                    }
                    Log.d(TAG, "json arr : " + arr);
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, arr.toString(), lCbId);
                } else {
                    Log.e(TAG, "Error", res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCbId);
                }
            }
        });
    }

    @Override
    public String getObject(String colectionName, String objId) {
        return "Baasbox is not support";
    }

    @Override
    public void findObjectInBackground(String colectionName, String whereKey, String equalTo, int callbackID) {
        final long lCbId = (long)callbackID;

        Criteria filter = BaasQuery.builder()
                .pagination(0, 20)
                .orderBy("id")
                .where(whereKey + " = ?")
                .whereParams(equalTo)
                .criteria();

        BaasDocument.fetchAll(colectionName, filter, new BaasHandler<List<BaasDocument>>() {
            @Override
            public void handle(BaasResult<List<BaasDocument>> res) {
                if (res.isSuccess()) {
                    JsonArray arr = new JsonArray();
                    for (BaasDocument doc : res.value()) {
                        arr.add(doc.toJson());
                    }
                    Log.d(TAG,"json arr : "+arr);
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, arr.toString(), lCbId);
                } else {
                    Log.e(TAG, "Error", res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter,false,makeErrorJsonString(res.error()),lCbId);
                }
            }
        });
    }

    @Override
    public void findObjectsInBackground(String colectionName, String whereKey, String stringJsonArrayValue, int cbID){
        Log.d(TAG, "findObjectsInBackground wherekey " + whereKey + " string array id " + stringJsonArrayValue);

        JsonArray arrVl = JsonArray.decode(stringJsonArrayValue);

        final long lCbId = (long)cbID;

        BaasQuery.Builder builder = BaasQuery.builder()
                .pagination(0, 20)
                .orderBy("id")
                .where(whereKey + " = " + "'" + arrVl.get(0, "") + "'");

        // String.format("%s = '%s'", whereKey, arrVl.get(0, ""))

        for (int i = 1; i < arrVl.size(); i++) {
            builder.or(whereKey + " = " + "'" + arrVl.get(i, "") + "'");
        }

        BaasQuery.Criteria filter = builder.criteria();

        BaasDocument.fetchAll(colectionName, filter, new BaasHandler<List<BaasDocument>>() {
            @Override
            public void handle(BaasResult<List<BaasDocument>> res) {
                if (res.isSuccess()) {
                    JsonArray arr = new JsonArray();
                    for (BaasDocument doc : res.value()) {
                        arr.add(doc.toJson());
                    }
                    Log.d(TAG, "json arr : " + arr);
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, arr.toString(), lCbId);
                } else {
                    Log.e(TAG, "Error", res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCbId);
                }
            }
        });
    }

    @Override
    public void updateObjectInBackground(String collectionName, String objId,
                                         final String jsonChanges, int callbackID) {
        Log.d(TAG, "updateObjectInBackground collectionName : " + collectionName + " objid : " + objId);

        final long lCbId = (long)callbackID;
        BaasDocument doc = BaasDocument.create(collectionName,objId);

        JsonObject jsonObj = JsonObject.decode(jsonChanges);
        Iterator v1 = jsonObj.iterator();
        while (v1.hasNext()) {
            Map.Entry e = (Map.Entry) v1.next();
            String key = (String) e.getKey();
            Object value = e.getValue();
            BaasDocumentPutObject(doc,key,value);
        }
        doc.save(SaveMode.IGNORE_VERSION, new BaasHandler<BaasDocument>() {
            @Override
            public void handle(BaasResult<BaasDocument> res) {
                if (res.isSuccess()) {
                    Log.d(TAG, "Document update " + res.value().getId());
                    BaasDocument d = res.value();
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, d.toJson().toString(), lCbId);
                } else {
                    Log.e(TAG, "Error", res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCbId);
                }
            }
        });

    }

    @Override
    public String updateObject(String colectionName, String objId,
                               String jsonChanges) {
        return "Baasbox is not support";
    }

    @Override
    public void deleteObjectInBackground(String collectionName, String objId, int callbackID) {
        final long lCbId = (long)callbackID;
        BaasDocument doc = BaasDocument.create(collectionName,objId);
        doc.delete(new BaasHandler<Void>() {
            @Override
            public void handle(BaasResult<Void> res) {
                if (res.isSuccess()) {
                    Log.d(TAG, "Document deleted");
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, "Document deleted", lCbId);
                } else {
                    Log.e(TAG, "error",res.error());
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(res.error()), lCbId);
                }
            }
        });
    }

    public String deleteObject(String colectionName, String objId) {
        return "Baasbox is not support";
    }

    public void loadAssetJSON(String assetName, int cbId){
        final long lCbId = (long)cbId;
        Log.d(TAG,"loadAssetJSON");
        BaasAsset.fetchData(assetName, new BaasHandler<JsonObject>() {
            @Override
            public void handle(BaasResult<JsonObject> baasResult) {
                if(baasResult.isSuccess()){
                    JsonObject d = baasResult.value();
                    BaaSWrapper.onBaaSActionResult(mAdapter, true, d.toString(), lCbId);
                }else{
                    BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(baasResult.error()), lCbId);
                }
            }
        });
    }
}


