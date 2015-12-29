#include "ParseProtocolBaaS.h"
#include "PluginUtils.h"
#include <string>

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;

ParseProtocolBaaS::~ParseProtocolBaaS() {
	PluginUtils::erasePluginJavaData(this);
};

std::string ParseProtocolBaaS::getUserInfo() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserInfo");
}

std::string ParseProtocolBaaS::setUserInfo(const std::string& changes) {
	PluginParam param(changes.c_str());
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

void ParseProtocolBaaS::subcribeChannel(const std::string& channel) {
	PluginParam param(channel.c_str());
	PluginUtils::callJavaFunctionWithName_oneParam(this, "subcribeChannel", "(Ljava/lang/String;)V", &param);
}

void ParseProtocolBaaS::unsubcribeChannel(const std::string& channel) {
	PluginParam param(channel.c_str());
	PluginUtils::callJavaFunctionWithName_oneParam(this, "unsubcribeChannel", "(Ljava/lang/String;)V", &param);
}
