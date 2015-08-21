#include "AdmobProtocolAds.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_ADS;
using namespace cocos2d::plugin;

AdmobProtocolAds::AdmobProtocolAds() {
}

AdmobProtocolAds::~AdmobProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void AdmobProtocolAds::configureAds(const std::string &adsId) {
    TAdsDeveloperInfo devInfo;
    devInfo["AdmobID"] = adsId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string &deviceId) {
    PluginParam deviceIdParam(deviceId.c_str());
    callFuncWithParam("addTestDevice", &deviceIdParam, nullptr);
}
