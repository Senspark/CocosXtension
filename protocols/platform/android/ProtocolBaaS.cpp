#include "ProtocolBaaS.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"

using namespace std;
namespace cocos2d {
namespace plugin {

extern "C" {

JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_BaaSWrapper_nativeOnBaaSActionResult(JNIEnv* env, jobject thiz, jstring className, jboolean returnCode, jstring result, jlong cbID) {
	std::string strResult = PluginJniHelper::jstring2string(result);
	std::string strClassName = PluginJniHelper::jstring2string(className);
	PluginProtocol* pPlugin = PluginUtils::getPluginPtr(strClassName);
	PluginUtils::outputLog("ProtocolBaaS", "nativeOnBaaSActionResult(), Get plugin ptr : %p", pPlugin);

	if (pPlugin != nullptr) {
		PluginUtils::outputLog("ProtocolBaaS", "nativeOnBaaSActionResult(), Get plugin name : %s", pPlugin->getPluginName());
		ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
		PluginUtils::outputLog("ProtocolBaaS", "Get pUser : %p", pBaaS);

		if (pBaaS != nullptr && cbID) {
			ProtocolBaaS::CallbackWrapper* wrapper = (ProtocolBaaS::CallbackWrapper*) cbID;
			PluginUtils::outputLog("ProtocolBaaS", "Wrapper: %p", wrapper);
			PluginUtils::outputLog("ProtocolBaaS", "cbID : %p", cbID);

			wrapper->fnPtr(returnCode, strResult);
			PluginUtils::outputLog("ProtocolBaaS", "End", cbID);
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
			"(J)V")) {

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

void ProtocolBaaS::findObjectsInBackground(const std::string& className, const std::string& key, const std::vector<std::string>& value, BaaSCallback& cb) {

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

std::string ProtocolBaaS::getUserID() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserID");
}


}
}
