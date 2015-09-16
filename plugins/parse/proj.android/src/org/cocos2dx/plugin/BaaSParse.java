package org.cocos2dx.plugin;

import java.util.Hashtable;
import java.util.Iterator;

import org.cocos2dx.plugin.BaaSWrapper;
import org.cocos2dx.plugin.InterfaceBaaS;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.parse.GetCallback;
import com.parse.LogInCallback;
import com.parse.LogOutCallback;
import com.parse.Parse;
import com.parse.ParseAnalytics;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.SignUpCallback;

public class BaaSParse implements InterfaceBaaS {
	private static final String LOG_TAG = "BaaSParse";
	private static Activity mContext = null;
	private static boolean mDebug = true;
	private static BaaSParse mAdapter = null;
	
	public static final int RESULT_CODE_LoginSucceed = 0;
	public static final int RESULT_CODE_LoginFailed = 1;
	public static final int RESULT_CODE_LogoutSucceed = 2;
	public static final int RESULT_CODE_LogoutFailed = 3;
	public static final int RESULT_CODE_SignUpSucceed = 4;
	public static final int RESULT_CODE_SignUpFailed = 5;
	public static final int RESULT_CODE_SaveSucceed = 6;
	public static final int RESULT_CODE_SaveFailed = 7;
	public static final int RESULT_CODE_RetrieveSucceed = 8;
	public static final int RESULT_CODE_RetrieveFailed = 9;
	public static final int RESULT_CODE_DeleteSucceed = 10;
	public static final int RESULT_CODE_DeleteFailed = 11;
	public static final int RESULT_CODE_UpdateSucceed = 12;
	public static final int RESULT_CODE_UpdateFailed = 13;
	
	public void logD(String msg) {
		if (mDebug) {
			Log.d(LOG_TAG, msg);
		}
	}
	
	public BaaSParse(Context context) {
		mContext = (Activity) context;
		mAdapter = this;
	}
	
	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		String appId = devInfo.get("ParseApplicationId");
		String clientKey = devInfo.get("ParseClientKey");
		
		Parse.enableLocalDatastore(mContext);
		Parse.initialize(mContext, appId, clientKey);
		ParseAnalytics.trackAppOpenedInBackground(mContext.getIntent());
	}

	@Override
	public void signUp(Hashtable<String, String> userInfo) {
		ParseUser user = new ParseUser();
		user.setUsername(userInfo.get("username"));
		user.setPassword(userInfo.get("password"));
		user.setEmail(userInfo.get("email"));
		
		for (String key : userInfo.keySet()) {
			if ("username".compareTo(key) != 0 && "password".compareTo(key) != 0 && "email".compareTo(key) != 0) {
				user.put(key, userInfo.get(key));
			}
		}
		
		user.signUpInBackground(new SignUpCallback() {
			@Override
			public void done(ParseException e) {

				if (e == null) {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_SignUpSucceed, makeErrorJsonString(e));
				} else {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_SignUpFailed, makeErrorJsonString(e));
				}
			}
		});
	}

	@Override
	public void login(String userName, String password) {
		ParseUser.logInInBackground(userName, password, new LogInCallback() {
			
			@Override
			public void done(ParseUser user, ParseException e) {
				if (e == null) {
		            BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_LoginSucceed, makeErrorJsonString(e)); 
		            
		            Log.i(LOG_TAG, "Login successfully.");
		        } else {
		        	BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_LoginFailed, makeErrorJsonString(e));
		            
		            Log.i(LOG_TAG, "Error when logging in. Error: " + e.getMessage());
		        }
			}
		});
	}

	@Override
	public void logout() {
		ParseUser.logOutInBackground(new LogOutCallback() {
			@Override
			public void done(ParseException e) {
				if (e == null) {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_LogoutSucceed, makeErrorJsonString(e));
					
					Log.i(LOG_TAG, "Logout successfully");
				} else {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_LogoutFailed, makeErrorJsonString(e));
					
					Log.i(LOG_TAG, "Logout error.");
				}
			}
		});
	}

	@Override
	public boolean isLoggedIn() {
		return ParseUser.getCurrentUser() != null;
	}
	
	private void updateParseObject(ParseObject parseObj, JSONObject jsonObj) throws JSONException {
		for (Iterator<String> iter = jsonObj.keys(); iter.hasNext();) {
			String key = iter.next();
			logD("Key: " + key);
			logD("Field: " + jsonObj.get(key).toString());
			parseObj.put(key, jsonObj.get(key));
		}
	}
	
	private ParseObject convertJSONObject(String className, JSONObject jsonObj)  throws JSONException {
		ParseObject parseObj = new ParseObject(className);
		
		updateParseObject(parseObj, jsonObj);
		
		return parseObj;
	}

	@Override
	public void saveObjectInBackground(String className, String json) {
		try {
			JSONObject jsonObj = new JSONObject(json);
			final ParseObject parseObj = convertJSONObject(className, jsonObj);

			parseObj.saveInBackground(new SaveCallback() {
				@Override
				public void done(ParseException e) {
					if (e == null) {
						BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_SaveSucceed, parseObj.getObjectId());
						Log.i(LOG_TAG, "Save object successfully.");
					} else {
						BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_SaveFailed, makeErrorJsonString(e));
						Log.i(LOG_TAG, "Error when saving object. Error: " + e.getMessage());
					}
				}
			});
		} catch (JSONException ex) {
			BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_SaveFailed, null);
			Log.i(LOG_TAG, "Error when parse json string.");
		}
	}

	@Override
	public String saveObject(String className, String json) {
		try {
			JSONObject jsonObj = new JSONObject(json);
		    ParseObject parseObj = convertJSONObject(className, jsonObj);
			parseObj.save();
			
			Log.i(LOG_TAG, "Saving object successfully.");
			return parseObj.getObjectId();
			
		} catch (JSONException ex) {
			Log.i(LOG_TAG, "Error when parse json string. " + ex.getMessage());
		} catch (ParseException ex) {
			Log.i(LOG_TAG, "Error when saving parse object. " + ex.getMessage());
		}
		
		return null;
	}
	
	@Override
	public void getObjectInBackground(String className, String objId) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
		query.getInBackground(objId, new GetCallback<ParseObject>() {
			
			@Override
			public void done(ParseObject obj, ParseException e) {
				if (e == null) {
					JSONObject jsonObj = new JSONObject();
					
					try {
						for (String key : obj.keySet()) {
							jsonObj.accumulate(key, obj.get(key));
						}
						
						BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_RetrieveSucceed, jsonObj.toString());
						Log.i(LOG_TAG, "Retrieve object successfully. ");
					} catch (JSONException ex) {
						BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_RetrieveFailed, null);
						Log.i(LOG_TAG, "Error when converting parse object to json. " + ex.getMessage());
					}
 					
				} else {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_RetrieveFailed, makeErrorJsonString(e));
					Log.i(LOG_TAG, "Error when retrieve object. " + e.getMessage());
				}
			}
		});
	}

	@Override
	public String getObject(String className, String objId) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
		
		JSONObject jsonObj = new JSONObject();
		try {
			ParseObject parseObj = query.get(objId);
			
			for (String key : parseObj.keySet()) {
				jsonObj.accumulate(key, parseObj.get(key));
			}
			Log.i(LOG_TAG, "Retrieve object successfully.");
			return jsonObj.toString();
		} catch (JSONException ex) {
			Log.i(LOG_TAG, "Error when converting parse object to json. " + ex.getMessage());
		} catch (ParseException ex) {
			Log.i(LOG_TAG, "Error when retrieve object. " + ex.getMessage());
		}
		
		return null;
	}

	@Override
	public void updateObjectInBackground(String className, String objId,
			final String jsonChanges) {
		ParseQuery<ParseObject>	query = ParseQuery.getQuery(className);
		
		query.getInBackground(objId, new GetCallback<ParseObject>() {
			@Override
			public void done(final ParseObject parseObj, ParseException e) {
				if (e == null) {
					try {
						JSONObject jsonObj = new JSONObject(jsonChanges);
						updateParseObject(parseObj, jsonObj);
						
						parseObj.saveInBackground(new SaveCallback() {
							
							@Override
							public void done(ParseException e) {
								if (e == null) {
									BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_RetrieveSucceed, parseObj.getObjectId());
									Log.i(LOG_TAG, "Update object successfully. ");
								} else {
									BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_UpdateFailed, makeErrorJsonString(e));
									Log.i(LOG_TAG, "Error when saving object. " + e.getMessage());
								}
							}
						});
					} catch (JSONException ex) {
						BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_RetrieveFailed, null);
						Log.i(LOG_TAG, "Error when converting parse object to json. " + ex.getMessage());
					}
				} else {
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_UpdateFailed, makeErrorJsonString(e));
				}
			}
		});
	}

	@Override
	public String updateObject(String className, String objId,
			String jsonChanges) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
		try {
			ParseObject parseObj = query.get(objId);
			JSONObject jsonObj = new JSONObject(jsonChanges);
			updateParseObject(parseObj, jsonObj);
			
			parseObj.save();
			return parseObj.getObjectId();
			
		} catch (ParseException ex) {
			Log.i(LOG_TAG, "Error when read/write parse object. " + ex.getMessage());
		} catch (JSONException ex) {
			Log.i(LOG_TAG, "Error when converting json object. " + ex.getMessage());
		}
		
		return null;
	}

	public static String makeErrorJsonString(ParseException e) {
		if (e != null) {
			try {
				
				JSONObject json = new JSONObject();
				
				json.accumulate("code", e.getCode());
				json.accumulate("description", e.getMessage());
			
				return json.toString();
				
			} catch (JSONException ex) {
				Log.i(LOG_TAG, "Error when making json.");
			}
		}
		
		return null;
	}
}
