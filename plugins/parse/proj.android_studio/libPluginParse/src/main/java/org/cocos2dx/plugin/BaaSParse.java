package org.cocos2dx.plugin;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.facebook.AccessToken;
import com.parse.ConfigCallback;
import com.parse.DeleteCallback;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.LogInCallback;
import com.parse.LogOutCallback;
import com.parse.Parse;
import com.parse.ParseAnalytics;
import com.parse.ParseConfig;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.parse.SignUpCallback;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;

public class BaaSParse implements InterfaceBaaS {
	private static final String LOG_TAG = "BaaSParse";
	private static Activity mContext 	= null;
	private static boolean mDebug 		= true;
	private static BaaSParse mAdapter 	= null;
	private static ParseConfig mCurrentConfig = null;
		
	public BaaSParse(Context context) {
		mContext = (Activity) context;
		mAdapter = this;
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
	
	public void logD(String msg) {
		if (mDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		Log.i(LOG_TAG, "BAASPARSE CONFIGDEVELOPERINFO ...");
		String appId = devInfo.get("ParseApplicationId");
		String clientKey = devInfo.get("ParseClientKey");

		boolean enableLocalDatastore = "true".compareTo(devInfo.get("ParseEnableLocalDatastore")) == 0;
		boolean enableFacebookUtils  = "true".compareTo(devInfo.get("ParseEnableFacebookUtils")) == 0;

		if (enableLocalDatastore) {
			Parse.enableLocalDatastore(mContext);
		}

		Parse.initialize(mContext, appId, clientKey);

		if (enableFacebookUtils) {
			ParseFacebookUtils.initialize(mContext);
		}

		ParseAnalytics.trackAppOpenedInBackground(mContext.getIntent());

		mCurrentConfig = ParseConfig.getCurrentConfig();
	}

	@Override
	public void signUp(Hashtable<String, String> userInfo, int callbackID) {
		final int cbID = callbackID;
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
					BaaSWrapper.onBaaSActionResult(mAdapter, true, makeErrorJsonString(e), cbID);
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
				}
			}
		});
	}

	@Override
	public void login(String userName, String password, int callbackID) {
		final int cbID = callbackID;
		ParseUser.logInInBackground(userName, password, new LogInCallback() {

			@Override
			public void done(ParseUser user, ParseException e) {
				if (e == null) {
					BaaSWrapper.onBaaSActionResult(mAdapter, true, makeErrorJsonString(e), cbID);

					Log.i(LOG_TAG, "Login successfully.");
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);

					Log.i(LOG_TAG, "Error when logging in. Error: " + e.getMessage());
				}
			}
		});
	}

	@Override
	public void logout(int callbackID) {
		final int cbID = callbackID;
		ParseUser.logOutInBackground(new LogOutCallback() {
			@Override
			public void done(ParseException e) {
				if (e == null) {
					BaaSWrapper.onBaaSActionResult(mAdapter, true, makeErrorJsonString(e), cbID);

					Log.i(LOG_TAG, "Logout successfully");
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);

					Log.i(LOG_TAG, "Logout error.");
				}
			}
		});
	}
	
	@Override
	public boolean isLoggedIn() {
		return ParseUser.getCurrentUser() != null;
	}

	@Override
	public String getUserID() {
		ParseUser currentUser = ParseUser.getCurrentUser();
		if (currentUser != null) {
			Log.i(LOG_TAG, "BaaSParse getUserID: " + ParseUser.getCurrentUser().getObjectId());
			return ParseUser.getCurrentUser().getObjectId();
		}
		return "";
	}
	
	private void updateParseObject(ParseObject parseObj, JSONObject jsonObj) throws JSONException {
		for (Iterator<String> iter = jsonObj.keys(); iter.hasNext();) {
			String key = iter.next();
			logD("Key: " + key);
			logD("Field: " + jsonObj.get(key).toString());
			parseObj.put(key, jsonObj.get(key));
		}
	}

	public String getUserInfo() {
		Log.e(LOG_TAG, "ParseUser: " + convertPFUserToJson(ParseUser.getCurrentUser()).toString());
		return convertPFUserToJson(ParseUser.getCurrentUser()).toString();
	}

	public String setUserInfo(String jsonData) {
		Log.e(LOG_TAG, "jsonData: " + jsonData);
		try {
			JSONObject jObject = new JSONObject(jsonData);

			ParseUser pUser = ParseUser.getCurrentUser();

			if (pUser != null) {
				Iterator<String> iter = jObject.keys();

				while (iter.hasNext()) {
					String key = iter.next();

					pUser.put(key, jObject.get(key));
				}

				return getUserInfo();
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		return "";
	}

	public void saveUserInfo(final int callbackID) {
		final ParseUser pUser = ParseUser.getCurrentUser();
		if (pUser != null) {
			pUser.saveInBackground(new SaveCallback() {
				@Override
				public void done(ParseException e) {
					if (e == null) {
						BaaSWrapper.onBaaSActionResult(mAdapter, true, convertPFUserToJson(pUser).toString(), callbackID);
					} else {
						BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), callbackID);
					}
				}
			});
		} else {
			BaaSWrapper.onBaaSActionResult(mAdapter, false, "", callbackID);
		}
	}

	public String getInstallationInfo() {
		return ParseInstallation.getCurrentInstallation().toString();
	}
	
	public void setInstallationInfo(String jsonData) {
		Log.e(LOG_TAG, "BaaSParse does not support setInstallationInfo");
	}
	
	public String getSubscribedChannels() {
		return ParseInstallation.getCurrentInstallation().getList("channels").toArray().toString();		
	}
	
	public void subscribeChannels(final String channelList) {

		Log.e(LOG_TAG, "CHANNELS: " + Arrays.asList(channelList.split(",")));

		ParseInstallation.getCurrentInstallation().addAllUnique("channels", Arrays.asList(channelList.split(",")));
		ParseInstallation.getCurrentInstallation().saveEventually(new SaveCallback() {
			@Override
			public void done(ParseException e) {
				if (e == null) {
					Log.i(LOG_TAG, "PARSE PUSH SUBSCRIBE TO CHANNEL " + channelList + " SUCCEEDED");
				} else {
					Log.e(LOG_TAG, "PARSE PUSH SUBSCRIBE TO CHANNEL " + channelList + " FAILED WITH ERROR " + e.getMessage());
				}
			}
		});
	}
	
	public void unsubscribeChannels(final String channelList) throws JSONException {
		JSONArray array = new JSONArray(channelList);

		List<String> subcribed = ParseInstallation.getCurrentInstallation().getList("channels");

		for (int i = 0; i < array.length(); i++) {
			if (subcribed.contains(array.get(i))) {
				subcribed.remove(array.get(i));
			}
		}

		ParseInstallation.getCurrentInstallation().put("channels", subcribed);
		ParseInstallation.getCurrentInstallation().saveEventually(new SaveCallback() {
			@Override
			public void done(ParseException e) {
				if (e == null) {
					Log.i(LOG_TAG, "PARSE PUSH UNSUBSCRIBE TO CHANNEL " + channelList + "SUCCEEDED");
				} else {
					Log.e(LOG_TAG, "PARSE PUSH UNSUBSCRIBE TO CHANNEL " + channelList + "FAILED WITH ERROR " + e.getMessage());
				}
			}
		});
	}
	
	private ParseObject convertJSONObject(String className, JSONObject jsonObj)  throws JSONException {
		ParseObject parseObj = new ParseObject(className);

		updateParseObject(parseObj, jsonObj);

		return parseObj;
	}

	@Override
	public void saveObjectInBackground(String className, String json, int callbackID) {
		final int cbID = callbackID;
		try {
			JSONObject jsonObj = new JSONObject(json);
			final ParseObject parseObj = convertJSONObject(className, jsonObj);

			parseObj.saveInBackground(new SaveCallback() {
				@Override
				public void done(ParseException e) {
					if (e == null) {
						BaaSWrapper.onBaaSActionResult(mAdapter, true, parseObj.getObjectId(), cbID);
						Log.i(LOG_TAG, "Save object successfully.");
					} else {
						BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
						Log.i(LOG_TAG, "Error when saving object. Error: " + e.getMessage());
					}
				}
			});
		} catch (JSONException ex) {
			BaaSWrapper.onBaaSActionResult(mAdapter, false, null, cbID);
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
	public void findObjectsInBackground(String className, String whereKey, String containInArray, int callbackID) {
		final int cbID = callbackID;
		try {
			JSONArray jArray = new JSONArray(containInArray);

			ArrayList<String> listdata = new ArrayList<String>();
			if (jArray != null) {
				for (int i=0; i<jArray.length(); i++){
					listdata.add(jArray.get(i).toString());
				}
			}

			ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
			query.whereContainedIn(whereKey, listdata);
			query.findInBackground(new FindCallback<ParseObject>() {

				@Override
				public void done(List<ParseObject> listObjects, ParseException error) {

					if (error != null) {
						BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(error), cbID);
					} else {
						ArrayList<JSONObject> objects = new ArrayList<>();
						for (ParseObject obj : listObjects) {
							objects.add(convertPFObjectToJson(obj));
						}

						BaaSWrapper.onBaaSActionResult(mAdapter, true, String.valueOf(objects), cbID);
					}
				}
			});

		} catch (JSONException e) {
			Log.e(LOG_TAG, "Error when parse JSONArray: " + e.getMessage());
		}
	}
	
	@Override
	public void findObjectInBackground(String className, String whereKey, String equalTo, int callbackID) {
		final int cbID = callbackID;
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
		query.whereEqualTo(whereKey, equalTo);
		query.getFirstInBackground(new GetCallback<ParseObject>() {

			@Override
			public void done(ParseObject obj, ParseException e) {
				if (e == null) {
					JSONObject jsonObj = convertPFObjectToJson(obj);
					BaaSWrapper.onBaaSActionResult(mAdapter, true, jsonObj != null ? jsonObj.toString() : "", cbID);
					Log.i(LOG_TAG, "Retrieve object successfully. ");


				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
					Log.i(LOG_TAG, "Error when retrieve object. " + e.getMessage());
				}
			}
		});
	}
	
	@Override
	public void getObjectInBackground(String className, String objId, int callbackID) {
		final int cbID = callbackID;
		ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
		query.getInBackground(objId, new GetCallback<ParseObject>() {

			@Override
			public void done(ParseObject obj, ParseException e) {
				if (e == null) {

					JSONObject jsonObj = convertPFObjectToJson(obj);
					BaaSWrapper.onBaaSActionResult(mAdapter, true, jsonObj != null ? jsonObj.toString() : "", cbID);
					Log.i(LOG_TAG, "Retrieve object successfully. ");

				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
					Log.i(LOG_TAG, "Error when retrieve object. " + e.getMessage());
				}
			}
		});
	}

	@Override
	public void getObjectsInBackground(String className, String objIds, int callbackID) {
		final int cbID = callbackID;
		try {
			JSONArray jArray = new JSONArray(objIds);

			ArrayList<String> listdata = new ArrayList<String>();
			if (jArray != null) {
				for (int i=0; i<jArray.length(); i++){
					listdata.add(jArray.get(i).toString());
				}
			}

			ParseQuery<ParseObject> query = ParseQuery.getQuery(className);
			query.whereContainedIn("objectId", listdata);
			query.findInBackground(new FindCallback<ParseObject>() {

				@Override
				public void done(List<ParseObject> listObjects, ParseException error) {

					if (error != null) {
						BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(error), cbID);
					} else {
						BaaSWrapper.onBaaSActionResult(mAdapter, true, listObjects.toArray().toString(), cbID);
					}
				}
			});

		} catch (JSONException e) {
			Log.e(LOG_TAG, "Error when parse JSONArray: " + e.getMessage());
		}
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
			final String jsonChanges, int callbackID) {
		final int cbID = callbackID;
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
									BaaSWrapper.onBaaSActionResult(mAdapter, true, parseObj.getObjectId(), cbID);
									Log.i(LOG_TAG, "Update object successfully. ");
								} else {
									BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
									Log.i(LOG_TAG, "Error when saving object. " + e.getMessage());
								}
							}
						});
					} catch (JSONException ex) {
						BaaSWrapper.onBaaSActionResult(mAdapter, false, null, cbID);
						Log.i(LOG_TAG, "Error when converting parse object to json. " + ex.getMessage());
					}
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
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
	public void deleteObjectInBackground(String className, String objId, int callbackID) {
		final int cbID = callbackID;
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
								BaaSWrapper.onBaaSActionResult(mAdapter, true, null, cbID);

							} else {
								Log.e("Parse", "Delete object in background failed with error: " + arg0);
								BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(arg0), cbID);
							}
						}
					});

				} else {
					Log.e("Parse", "Cannot find object for deleting");
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
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

	public void fetchUserInfo(final int callbackID) {
		ParseUser pUser = ParseUser.getCurrentUser();
		pUser.fetchInBackground(new GetCallback<ParseObject>() {
			@Override
			public void done(ParseObject parseObject, ParseException e) {
				if (e == null) {
					BaaSWrapper.onBaaSActionResult(mAdapter, true, convertPFObjectToJson(parseObject).toString(), callbackID);
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), callbackID);
				}
			}
		});
	}

	public void fetchConfigInBackground(int callbackID) {
		final int cbID = callbackID;

		Log.i("BaaSParse", "Callback address: " + callbackID);
		ParseConfig.getInBackground(new ConfigCallback() {

			@Override
			public void done(ParseConfig config, ParseException e) {
				if (config != null && e == null) {
					Log.i("Parse", "Fetch config from server successfully");
					mCurrentConfig = config;
					BaaSWrapper.onBaaSActionResult(mAdapter, true, "Fetch config from server successfully", cbID);
				} else {
					Log.e("Parse", "Fetch config from server failed. Use current config instead");
					mCurrentConfig = ParseConfig.getCurrentConfig();
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
				}
			}
		});
	}

	public boolean getBoolConfig(String param) {
		boolean ret = mCurrentConfig.getBoolean(param, false);
		Log.i("Parse", "Parse Config >>> Get bool: " + ret);
		return ret;
	}

	public int getIntegerConfig(String param) {
		int ret = mCurrentConfig.getInt(param, 0);
		Log.i("Parse", "Parse Config >>> Get Integer: "+ ret);
		return ret;
	}

	public double getDoubleConfig(String param) {
		double ret = mCurrentConfig.getDouble(param, 0);
		Log.i("Parse", "Parse Config >>> Get Double: "+ ret);
		return ret;
	}

	public long getLongConfig(String param) {
		long ret = mCurrentConfig.getLong(param, 0);
		Log.i("Parse", "Parse Config >>> Get Long: "+ ret);
		return ret;
	}

	public String getStringConfig(String param) {
		String ret = mCurrentConfig.getString(param, "defaultString");
		Log.i("Parse", "Parse Config >>> Get String: "+ ret);
		return ret;
	}
	
	public String getArrayConfig(String param) {
		String ret = mCurrentConfig.getJSONArray(param).toString();
		Log.i("Parse", "Parse Config >>> Get Array: "+ ret);
		return ret;
	}

	public void loginWithFacebookAccessToken(int callbackID) {
		final int cbID = callbackID;
		ParseFacebookUtils.logInInBackground(AccessToken.getCurrentAccessToken(), new LogInCallback() {
			@Override
			public void done(ParseUser parseUser, ParseException e) {
				if (e == null) {
					BaaSWrapper.onBaaSActionResult(mAdapter, true, parseUser.getUsername(), cbID);
				} else {
					BaaSWrapper.onBaaSActionResult(mAdapter, false, makeErrorJsonString(e), cbID);
				}
			}
		});
	}


	private static JSONObject convertPFObjectToJson(ParseObject parseObject) {
		if (parseObject != null) {
			JSONObject jsonObj = new JSONObject();

			try {
				for (String key : parseObject.keySet()) {
					jsonObj.accumulate(key, parseObject.get(key));
				}

				jsonObj.accumulate("createdAt", parseObject.getCreatedAt().getTime());
				jsonObj.accumulate("updatedAt", parseObject.getUpdatedAt().getTime());

				return jsonObj;
			} catch (JSONException ex) {
				Log.i(LOG_TAG, "Error when converting parse object to json. " + ex.getMessage());

				return null;
			}
		}

		return null;
	}

	private static JSONObject convertPFUserToJson(ParseUser parseUser) {
		JSONObject jsonObj = convertPFObjectToJson(parseUser);

		if (jsonObj != null) {
			try {
				jsonObj.put("isNew", parseUser.isNew());
			} catch (JSONException e) {
				e.printStackTrace();
				return null;
			}

			return jsonObj;
		}
		return null;
	}
}
