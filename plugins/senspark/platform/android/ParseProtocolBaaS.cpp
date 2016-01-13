#include "ParseProtocolBaaS.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;

ParseProtocolBaaS::~ParseProtocolBaaS() {
	PluginUtils::erasePluginJavaData(this);
};

std::string ParseProtocolBaaS::getUserInfo() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserInfo");
}

std::string ParseProtocolBaaS::setUserInfo(const std::string& jsonChanges) {
	PluginParam param(jsonChanges.c_str());
	return PluginUtils::callJavaStringFuncWithName_oneParam(this, "setUserInfo", "(Ljava/lang/String;)Ljava/lang/String;", &param);
}

void ParseProtocolBaaS::saveUserInfo(BaaSCallback& cb) {
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::callJavaFunctionWithName_oneParam(this, "saveUserInfo", "(J)V", (long) wrapper);
}

void ParseProtocolBaaS::fetchUserInfo(BaaSCallback& cb) {
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::callJavaFunctionWithName_oneParam(this, "fetchUserInfo", "(J)V", (long) wrapper);
}

std::string ParseProtocolBaaS::getInstallationInfo() {
	return PluginUtils::callJavaStringFuncWithName(this, "getInstallationInfo");
}

std::string ParseProtocolBaaS::setInstallationInfo(const std::string& changes) {
	PluginParam param(changes.c_str());
	return PluginUtils::callJavaStringFuncWithName_oneParam(this, "getInstallationInfo","(Ljava/lang/String;)Ljava/lang/String;", &param);
}

void ParseProtocolBaaS::saveInstallationInfo(BaaSCallback& cb) {
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::callJavaFunctionWithName_oneParam(this, "saveInstallationInfo", "(J)V", (long) wrapper);
}

void ParseProtocolBaaS::loginWithFacebookAccessToken(BaaSCallback& cb) {
	CallbackWrapper* wrapper = new CallbackWrapper(cb);
	PluginUtils::callJavaFunctionWithName_oneParam(this, "loginWithFacebookAccessToken", "(J)V", (long) wrapper);
}

void ParseProtocolBaaS::subscribeChannels(const std::string& channel) {
	PluginParam param(channel.c_str());
	PluginUtils::callJavaFunctionWithName_oneParam(this, "subcribeChannels", "(Ljava/lang/String;)V", &param);
}

void ParseProtocolBaaS::unsubscribeChannels(const std::string& channel) {
	PluginParam param(channel.c_str());
	PluginUtils::callJavaFunctionWithName_oneParam(this, "unsubcribeChannels", "(Ljava/lang/String;)V", &param);
}
