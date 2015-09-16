#include "ProtocolBaaS.h"
#include "PluginJniHelper.h"
#include <android/log.h>
#include "PluginUtils.h"
#include "PluginJavaData.h"

using namespace std;
namespace cocos2d { namespace plugin {

extern "C" {

JNIEXPORT void JNICALL Java_org_cocos2dx_plugin_BaaSWrapper_nativeOnActionResult(JNIEnv* env, jobject thiz, jstring className, jint code, jstring result) {
    std::string strResult = PluginJniHelper::jstring2string(result);
    std::string strClassName = PluginJniHelper::jstring2string(className);
    PluginProtocol* pPlugin = PluginUtils::getPluginPtr(strClassName);
    PluginUtils::outputLog("ProtocolBaaS", "nativeOnActionResult(), Get plugin ptr : %p", pPlugin);

    if (pPlugin != nullptr) {
        PluginUtils::outputLog("ProtocolUser", "nativeOnActionResult(), Get plugin name : %s", pPlugin->getPluginName());
        ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
        if (pBaaS != nullptr)
        {
            BaaSActionListener* listener = pBaaS->getActionListener();
            if (nullptr != listener)
            {
                listener->onActionResult(pBaaS, code, strResult.c_str());
            }
            else
            {
                ProtocolBaaS::ProtocolBaaSCallback callback = pBaaS->getCallback();
                if(callback)
                {
                    callback(code, strResult);
                }
                else
                {
                    PluginUtils::outputLog("Listener of plugin %s not set correctly", pPlugin->getPluginName());
                }
            }
        }
    }
}

}

ProtocolBaaS::ProtocolBaaS() : _listener(nullptr) {

}

ProtocolBaaS::~ProtocolBaaS() {

}

void ProtocolBaaS::configDeveloperInfo(TBaaSDeveloperInfo devInfo) {
    if (devInfo.empty()) {
        PluginUtils::outputLog("ProtocolBaaS", "The developer info is empty for %s!", this->getPluginName());
        return;
    } else {
        PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
        PluginJniMethodInfo t;
        if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
            jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

            t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
            t.env->DeleteLocalRef(obj_Map);
            t.env->DeleteLocalRef(t.classID);
        }
    }
}

void ProtocolBaaS::signUp(map<string, string> userInfo) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "signUp", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&userInfo);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolBaaS::signUp(std::map<std::string, std::string> userInfo, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    signUp(userInfo);
}

void ProtocolBaaS::login(const std::string& username, const std::string& password) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "login", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jusername = t.env->NewStringUTF(username.c_str());
        jstring jpassword = t.env->NewStringUTF(password.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jusername, jpassword);

        t.env->DeleteLocalRef(jusername);
        t.env->DeleteLocalRef(jpassword);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolBaaS::login(const std::string& username, const std::string& password,ProtocolBaaSCallback& cb) {
    setCallback(cb);
    login(username, password);
}

void ProtocolBaaS::logout() {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "logout", "()V")) {

        t.env->CallVoidMethod(pData->jobj, t.methodID);

        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolBaaS::logout(ProtocolBaaSCallback& cb) {
    setCallback(cb);
    logout();
}

bool ProtocolBaaS::isLoggedIn() {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "isLoggedIn", "()Z")) {

        jboolean ret = t.env->CallBooleanMethod(pData->jobj, t.methodID);

        t.env->DeleteLocalRef(t.classID);

        return ret;
    }
    return false;
}

void ProtocolBaaS::saveObjectInBackground(const std::string& className, const std::string& json) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "saveObjectInBackground", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jjson = t.env->NewStringUTF(json.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jjson);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jjson);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ProtocolBaaS::saveObjectInBackground(const std::string& className, const std::string& json, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    saveObjectInBackground(className, json);
}

const char* ProtocolBaaS::saveObject(const std::string& className, const std::string& json) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "saveObject", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jjson = t.env->NewStringUTF(json.c_str());

        jobject jobject_id = t.env->CallObjectMethod(pData->jobj, t.methodID, jclass_name, jjson);
        const char* object_id = t.env->GetStringUTFChars((jstring) jobject_id, nullptr);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jjson);
        t.env->DeleteLocalRef(t.classID);

        return object_id;
    }

    return nullptr;
}

void ProtocolBaaS::getObjectInBackground(const std::string& className, const std::string& objId) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "getObjectInBackground", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jobject_id = t.env->NewStringUTF(objId.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jobject_id);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jobject_id);
        t.env->DeleteLocalRef(t.classID);
    }

}

void ProtocolBaaS::getObjectInBackground(const std::string& className, const std::string& objId, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    getObjectInBackground(className, objId);
}

const char* ProtocolBaaS::getObject(const std::string& className, const std::string& objId) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "getObject", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jobject_id = t.env->NewStringUTF(objId.c_str());

        jobject jjson = t.env->CallObjectMethod(pData->jobj, t.methodID, jclass_name, jobject_id);
        const char* json = t.env->GetStringUTFChars((jstring) jjson, nullptr);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jobject_id);
        t.env->DeleteLocalRef(t.classID);

        return json;
    }

    return nullptr;
}

void ProtocolBaaS::updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "updateObjectInBackground", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jobject_id = t.env->NewStringUTF(objId.c_str());
        jstring jchanges = t.env->NewStringUTF(jsonChanges.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jclass_name, jobject_id, jchanges);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jobject_id);
        t.env->DeleteLocalRef(jchanges);
        t.env->DeleteLocalRef(t.classID);

    }
}

void ProtocolBaaS::updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    updateObjectInBackground(className, objId, jsonChanges);
}

const char* ProtocolBaaS::updateObject(const std::string& className, const std::string& objId, const std::string& jsonChanges) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "updateObject", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring jclass_name = t.env->NewStringUTF(className.c_str());
        jstring jobject_id = t.env->NewStringUTF(objId.c_str());
        jstring jchanges = t.env->NewStringUTF(jsonChanges.c_str());

        jobject jret_id = t.env->CallObjectMethod(pData->jobj, t.methodID, jclass_name, jobject_id, jchanges);
        const char* ret_id = t.env->GetStringUTFChars((jstring)jret_id, nullptr);

        t.env->DeleteLocalRef(jclass_name);
        t.env->DeleteLocalRef(jobject_id);
        t.env->DeleteLocalRef(jchanges);
        t.env->DeleteLocalRef(t.classID);

        return ret_id;
    }

    return nullptr;
}

}}
