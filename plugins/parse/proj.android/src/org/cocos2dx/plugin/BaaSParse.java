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

import com.parse.ConfigCallback;
import com.parse.DeleteCallback;
import com.parse.GetCallback;
import com.parse.LogInCallback;
import com.parse.LogOutCallback;
import com.parse.Parse;
import com.parse.ParseAnalytics;
import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.SignUpCallback;

public class BaaSParse implements InterfaceBaaS {
	private static final String LOG_TAG = "BaaSParse";
	private static Activity mContext 	= null;
	private static boolean mDebug 		= true;
	private static BaaSParse mAdapter 	= null;
	private static ParseConfig mCurrentConfig = null;
	
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
	public static final int RESULT_CODE_GetBoolConfig		= 16;
	public static final int RESULT_CODE_GetIntConfig		= 17;
	public static final int RESULT_CODE_GetDoubleConfig		= 18;
	public static final int RESULT_CODE_GetLongConfig		= 19;
	public static final int RESULT_CODE_GetStringConfig		= 20;
	
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
		
		mCurrentConfig = ParseConfig.getCurrentConfig();
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
	
	@Override
	public void deleteObjectInBackground(String className, String objId) {
		ParseQuery<ParseObject>	query = ParseQuery.getQuery(className);

		query.getInBackground(objId, new GetCallback<ParseObject>() {
			@Override
			public void done(final ParseObject parseObj, ParseException e) {
				if (e == null) {
					
					parseObj.deleteInBackground(new DeleteCallback() {
						
						@Override
						public void done(ParseException arg0) {
							if (arg0 == null) {
								Log.i("Parse", "Delete object in background successfully");
								BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_DeleteSucceed, null);

							} else {
								Log.e("Parse", "Delete object in background failed with error: " + arg0);
								BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_DeleteFailed, makeErrorJsonString(arg0));
							}
						}
					});

				} else {
					Log.e("Parse", "Cannot find object for deleting");
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_DeleteFailed, makeErrorJsonString(e));
				}
			}
		});
	}
	
	@Override
	public String deleteObject(String className, String objId) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
	 	try {
			ParseObject parseObj = query.get(objId);
			parseObj.deleteEventually();
			Log.i("Parse", "Delete object successfully");
			return "Delete object successfully";
		} catch (ParseException e) {
			Log.e(LOG_TAG, "Error when geting parse object. " + e.getMessage());
		}
		return "Delete object failed";
	}
	
	@Override
	public void fetchConfigInBackground() {
		ParseConfig.getInBackground(new ConfigCallback() {
			
			@Override
			public void done(ParseConfig config, ParseException e) {
				if (config != null && e == null) {
					Log.i("Parse", "Fetch config from server successfully");
					mCurrentConfig = config;
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_FetchConfigSucceed, "Fetch config from server successfully");
				} else {
					Log.e("Parse", "Fetch config from server failed. Use current config instead");
					mCurrentConfig = ParseConfig.getCurrentConfig();
					BaaSWrapper.onActionResult(mAdapter, RESULT_CODE_FetchConfigFailed, makeErrorJsonString(e));
				}
			}
		});
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

	@Override
	public boolean getBoolConfig(String param) {
		boolean ret = mCurrentConfig.getBoolean(param, false);
		Log.i("Parse", "Parse Config >>> Get bool: "+ ret);
		return ret;
	}

	@Override
	public int getIntegerConfig(String param) {
		int ret = mCurrentConfig.getInt(param, 0);
		Log.i("Parse", "Parse Config >>> Get Integer: "+ ret);
		return ret;
	}

	@Override
	public double getDoubleConfig(String param) {
		double ret = mCurrentConfig.getDouble(param, 0);
		Log.i("Parse", "Parse Config >>> Get Double: "+ ret);
		return ret;
	}

	@Override
	public long getLongConfig(String param) {
		long ret = mCurrentConfig.getLong(param, 0);
		Log.i("Parse", "Parse Config >>> Get Long: "+ ret);
		return ret;
	}

	@Override
	public String getStringConfig(String param) {
		String ret = mCurrentConfig.getString(param, "defaultString");
		Log.i("Parse", "Parse Config >>> Get String: "+ ret);
		return ret;
	}
}
