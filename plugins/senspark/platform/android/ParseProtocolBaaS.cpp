#include "ParseProtocolBaaS.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;
using namespace std;
using namespace cocos2d;

ParseProtocolBaaS::~ParseProtocolBaaS() {
    PluginUtils::erasePluginJavaData(this);
};

std::string ParseProtocolBaaS::getUserInfo() {
    return callStringFuncWithParam("getUserInfo", nullptr);
}

std::string ParseProtocolBaaS::setUserInfo(const std::string& jsonChanges) {
    PluginParam params(jsonChanges.c_str());

    return callStringFuncWithParam("setUserInfo", &params, nullptr);
}

void ParseProtocolBaaS::saveUserInfo(BaaSCallback &cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);

    PluginParam callbackParam((long long) wrapper);

    callFuncWithParam("saveUserInfo", &callbackParam, nullptr);
}

void ParseProtocolBaaS::fetchUserInfo(BaaSCallback &cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);

    PluginParam callbackParam((long long) wrapper);

    callFuncWithParam("fetchUserInfo", &callbackParam, nullptr);
}

std::string ParseProtocolBaaS::getInstallationInfo() {
	return callStringFuncWithParam("getInstallationInfo", nullptr);
}

std::string ParseProtocolBaaS::setInstallationInfo(const std::string& changes) {
    PluginParam params(changes.c_str());

    return callStringFuncWithParam("setInstallationInfo", &params, nullptr);
}

void ParseProtocolBaaS::saveInstallationInfo(BaaSCallback& cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    PluginParam callbackParam((long long) wrapper);
    callFuncWithParam("saveInstallationInfo", &callbackParam, nullptr);
}

void ParseProtocolBaaS::loginWithFacebookAccessToken(BaaSCallback& cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);

    PluginParam callbackParam((long long) wrapper);

    callFuncWithParam("loginWithFacebookAccessToken", &callbackParam, nullptr);
}


void ParseProtocolBaaS::subscribeChannels(const std::string &channels) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "subscribeChannels",
            "(Ljava/lang/String;)V")) {
        jstring jchannels = t.env->NewStringUTF(channels.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jchannels);

        t.env->DeleteLocalRef(jchannels);
        t.env->DeleteLocalRef(t.classID);
    }
}

void ParseProtocolBaaS::unsubscribeChannels(const std::string &channels) {
    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "unsubscribeChannels",
            "(Ljava/lang/String;)V")) {
        jstring jchannels = t.env->NewStringUTF(channels.c_str());

        t.env->CallVoidMethod(pData->jobj, t.methodID, jchannels);

        t.env->DeleteLocalRef(jchannels);
        t.env->DeleteLocalRef(t.classID);
    }
}

std::string ParseProtocolBaaS::getSubscribedChannels() {
    return callStringFuncWithParam("getSubscribedChannels", nullptr);
}


void ParseProtocolBaaS::fetchConfigInBackground(BaaSCallback& cb) {

    PluginJavaData* pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;

    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(), "fetchConfigInBackground", "(I)V")) {
        CallbackWrapper *wrapper = new CallbackWrapper(cb);

        t.env->CallVoidMethod(pData->jobj, t.methodID, (long) wrapper);
        t.env->DeleteLocalRef(t.classID);
    }
}

bool ParseProtocolBaaS::getBoolConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callBoolFuncWithParam("getBoolConfig", &pluginParam, nullptr);
}

int ParseProtocolBaaS::getIntegerConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callIntFuncWithParam("getIntegerConfig", &pluginParam, nullptr);
}

double ParseProtocolBaaS::getDoubleConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callDoubleFuncWithParam("getDoubleConfig", &pluginParam, nullptr);
}

long ParseProtocolBaaS::getLongConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callLongFuncWithParam("getLongConfig", &pluginParam, nullptr);
}

string ParseProtocolBaaS::getStringConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callStringFuncWithParam("getStringConfig", &pluginParam, nullptr);
}

string ParseProtocolBaaS::getArrayConfig(const std::string &param) {
    PluginParam pluginParam(param.c_str());

    return callStringFuncWithParam("getArrayConfig", &pluginParam, nullptr);
}
