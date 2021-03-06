#include "ProtocolBaaS.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"
#include <sstream>

using namespace std;
namespace cocos2d {
namespace plugin {

extern "C" {

JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_BaaSWrapper_nativeOnBaaSActionResult(JNIEnv* env, jobject thiz, jstring className, jboolean returnCode, jstring result, jlong cbID) {
	std::string strResult = PluginJniHelper::jstring2string(env, result);
	std::string strClassName = PluginJniHelper::jstring2string(env, className);
	bool boolRetCode = (bool) returnCode;
	PluginProtocol* pPlugin = PluginUtils::getPluginPtr(strClassName);
	PluginUtils::outputLog("ProtocolBaaS", "nativeOnBaaSActionResult(), Get plugin ptr : %p", pPlugin);

	if (pPlugin != nullptr) {
		PluginUtils::outputLog("ProtocolBaaS", "nativeOnBaaSActionResult(), Get plugin name : %s", pPlugin->getPluginName());
		PluginUtils::outputLog("ProtocolBaaS", "Class name: %s", strClassName.c_str());
		ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
		PluginUtils::outputLog("ProtocolBaaS", "Get pUser : %p", pBaaS);

		if (pBaaS != nullptr && cbID) {
			ProtocolBaaS::CallbackWrapper* wrapper = (ProtocolBaaS::CallbackWrapper*) cbID;
			PluginUtils::outputLog("ProtocolBaaS", "Wrapper: %p", wrapper);
			PluginUtils::outputLog("ProtocolBaaS", "cbID : %p", cbID);

			wrapper->fnPtr(boolRetCode, strResult);
			PluginUtils::outputLog("ProtocolBaaS", "End: %p", cbID);
			delete wrapper;
		} else {
			PluginUtils::outputLog("Listener of plugin %s not set correctly", pPlugin->getPluginName());
		}
	}
}
}

void ProtocolBaaS::configDeveloperInfo(TBaaSInfo devInfo) {
	if (devInfo.empty()) {
		PluginUtils::outputLog("ProtocolBaaS",
				"The developer info is empty for %s!", this->getPluginName());
		return;
	} else {
		PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
		PluginJniMethodInfo t;
		if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
				"configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
			jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

			t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
			t.env->DeleteLocalRef(obj_Map);
			t.env->DeleteLocalRef(t.classID);
		}
	}
}

void ProtocolBaaS::signUp(map<string, string> userInfo, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "signUp",
			"(Ljava/util/Hashtable;I)V")) {
		jobject obj_Map = PluginUtils::createJavaMapObject(&userInfo);

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map,
				(long) cbWrapper);
		t.env->DeleteLocalRef(obj_Map);
		t.env->DeleteLocalRef(t.classID);
	}
}

void ProtocolBaaS::login(const std::string& username,
		const std::string& password, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "login",
			"(Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jusername = t.env->NewStringUTF(username.c_str());
		jstring jpassword = t.env->NewStringUTF(password.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jusername, jpassword,
				(long) cbWrapper);

		t.env->DeleteLocalRef(jusername);
		t.env->DeleteLocalRef(jpassword);
		t.env->DeleteLocalRef(t.classID);
	}
}

void ProtocolBaaS::logout(BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "logout",
			"(I)V")) {

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, (long) cbWrapper);

		t.env->DeleteLocalRef(t.classID);
	}
}

bool ProtocolBaaS::isLoggedIn() {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"isLoggedIn", "()Z")) {

		jboolean ret = t.env->CallBooleanMethod(pData->jobj, t.methodID);

		t.env->DeleteLocalRef(t.classID);

		return ret;
	}
	return false;
}

std::string ProtocolBaaS::getUserID() {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"getUserID", "()Ljava/lang/String;")) {

		jobject obj = t.env->CallObjectMethod(pData->jobj, t.methodID);
		const char* ret = t.env->GetStringUTFChars((jstring) obj, nullptr);

		t.env->DeleteLocalRef(t.classID);

		return std::string(ret);
	}

    return nullptr;
}


void ProtocolBaaS::saveObjectInBackground(const std::string& className,
		const std::string& json, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"saveObjectInBackground",
			"(Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jjson = t.env->NewStringUTF(json.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jjson,
				(long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jjson);
		t.env->DeleteLocalRef(t.classID);
	}
}

const char* ProtocolBaaS::saveObject(const std::string& className,
		const std::string& json) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"saveObject", "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jjson = t.env->NewStringUTF(json.c_str());

		jobject jobject_id = t.env->CallObjectMethod(pData->jobj, t.methodID,
				jclass_name, jjson);
		const char* object_id = t.env->GetStringUTFChars((jstring) jobject_id,
				nullptr);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jjson);
		t.env->DeleteLocalRef(t.classID);

		return object_id;
	}

	return nullptr;
}

void ProtocolBaaS::getObjectInBackground(const std::string& className,
		const std::string& objId, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"getObjectInBackground",
			"(Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jobject_id,
				(long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(t.classID);
	}
}

void ProtocolBaaS::getObjectsInBackground(const std::string& className, const std::vector<std::string>& objIds, BaaSCallback& cb) {

		PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
		PluginJniMethodInfo t;

	    std::stringstream ss;
	    ss << "[";
	    for(size_t i = 0; i < objIds.size(); ++i)
	    {
	        if(i != 0)
	            ss << ",";
	        ss << objIds[i];
	    }
	    ss << "]";
	    std::string s = ss.str();

		if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
				"getObjectsInBackground",
				"(Ljava/lang/String;Ljava/lang/String;I)V")) {
			jstring jclass_name = t.env->NewStringUTF(className.c_str());
			jstring jids = t.env->NewStringUTF(s.c_str());

			CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

			t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jids, (long) cbWrapper);

			t.env->DeleteLocalRef(jclass_name);
			t.env->DeleteLocalRef(jids);
			t.env->DeleteLocalRef(t.classID);
		}
}


void ProtocolBaaS::findObjectInBackground(const std::string& className,
		const std::string& key, const std::string value, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"findObjectInBackground",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jkey = t.env->NewStringUTF(key.c_str());
		jstring jvalue = t.env->NewStringUTF(value.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jkey,
				jvalue, (long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jkey);
		t.env->DeleteLocalRef(jvalue);
		t.env->DeleteLocalRef(t.classID);
	}
}

void ProtocolBaaS::findObjectsInBackground(const std::string& className, const std::string& key, const std::vector<std::string>& values, BaaSCallback& cb){
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

    std::stringstream ss;
    ss << "[";
    for(size_t i = 0; i < values.size(); ++i)
    {
        if(i != 0)
            ss << ",";
        ss << values[i];
    }
    ss << "]";
    std::string s = ss.str();

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"findObjectsInBackground",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jkey = t.env->NewStringUTF(key.c_str());
		jstring jvalue = t.env->NewStringUTF(s.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jkey,
				jvalue, (long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jkey);
		t.env->DeleteLocalRef(jvalue);
		t.env->DeleteLocalRef(t.classID);
	}

}

const char* ProtocolBaaS::getObject(const std::string& className,
		const std::string& objId) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"getObject", "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());

		jobject jjson = t.env->CallObjectMethod(pData->jobj, t.methodID,
				jclass_name, jobject_id);
		const char* json = t.env->GetStringUTFChars((jstring) jjson, nullptr);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(t.classID);

		return json;
	}

	return nullptr;
}

void ProtocolBaaS::updateObjectInBackground(const std::string& className,
		const std::string& objId, const std::string& jsonChanges,
		BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"updateObjectInBackground",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());
		jstring jchanges = t.env->NewStringUTF(jsonChanges.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jobject_id,
				jchanges, (long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(jchanges);
		t.env->DeleteLocalRef(t.classID);

	}
}

const char* ProtocolBaaS::updateObject(const std::string& className,
		const std::string& objId, const std::string& jsonChanges) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"updateObject",
			"(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());
		jstring jchanges = t.env->NewStringUTF(jsonChanges.c_str());

		jobject jret_id = t.env->CallObjectMethod(pData->jobj, t.methodID,
				jclass_name, jobject_id, jchanges);
		const char* ret_id = t.env->GetStringUTFChars((jstring) jret_id,
				nullptr);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(jchanges);
		t.env->DeleteLocalRef(t.classID);

		return ret_id;
	}

	return nullptr;
}

void ProtocolBaaS::deleteObjectInBackground(const std::string& className,
		const std::string& objId, BaaSCallback& cb) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;

	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"deleteObjectInBackground",
			"(Ljava/lang/String;Ljava/lang/String;I)V")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());

		CallbackWrapper* cbWrapper = new CallbackWrapper(cb);

		t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jobject_id,
				(long) cbWrapper);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(t.classID);
	}
}

bool ProtocolBaaS::deleteObject(const std::string& className,
		const std::string& objId) {
	PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
	PluginJniMethodInfo t;
	if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
			"deleteObject", "(Ljava/lang/String;Ljava/lang/String;)Z")) {
		jstring jclass_name = t.env->NewStringUTF(className.c_str());
		jstring jobject_id = t.env->NewStringUTF(objId.c_str());

		jboolean ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,
				jclass_name, jobject_id);

		t.env->DeleteLocalRef(jclass_name);
		t.env->DeleteLocalRef(jobject_id);
		t.env->DeleteLocalRef(t.classID);

		return ret;
	}

	return nullptr;
}



}
}
