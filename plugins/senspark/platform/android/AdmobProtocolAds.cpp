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
    TAdsInfo devInfo;
    devInfo["AdmobID"] = adsId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string &deviceId) {
    PluginParam deviceIdParam(deviceId.c_str());
    callFuncWithParam("addTestDevice", &deviceIdParam, nullptr);
}

void AdmobProtocolAds::loadInterstitial() {
	callFuncWithParam("loadInterstitial", nullptr);
}

bool AdmobProtocolAds::hasInterstitial() {
	return callBoolFuncWithParam("hasInterstitial", nullptr);
}

void AdmobProtocolAds::setBannerAnimationInfo(int slideUpTimePeriod, int slideDownTimePeriod) {
    TAdsInfo devInfo;
    devInfo["slideUpTimePeriod"]    = slideUpTimePeriod;
    devInfo["slideDownTimePeriod"]  = slideDownTimePeriod;
    PluginParam param(devInfo);
    callFuncWithParam("setBannerAnimationInfo", &param, nullptr);
}

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideUpBannerAds", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideDownBannerAds", nullptr);
}
