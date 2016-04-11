#include "AdmobProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"
#include <sstream>

USING_NS_SENSPARK_PLUGIN_ADS;
using namespace cocos2d::plugin;
using namespace cocos2d;

std::string to_string(int input) {
    std::stringstream ss;
    ss << input;
    std::string ret(ss.str());
    return ret;
}

void AdmobProtocolAds::configMediationAdColony(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdColony", &pParam);
}

void AdmobProtocolAds::configMediationAdUnity(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdUnity", &pParam);
}

void AdmobProtocolAds::configMediationAdVungle(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdVungle", &pParam);
}

AdmobProtocolAds::~AdmobProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void AdmobProtocolAds::configureAds(const std::string &adsId, const std::string& appPublicKey) {
    TAdsInfo devInfo;
    devInfo["AdmobID"] = adsId;
    devInfo["AppPublicKey"] = appPublicKey;
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

void AdmobProtocolAds::loadRewardedAd() {
    callFuncWithParam("loadRewardedAd", nullptr);
}

void AdmobProtocolAds::showRewardedAd() {
    callFuncWithParam("showRewardedAd", nullptr);
}

bool AdmobProtocolAds::hasRewardedAd() {
    return callBoolFuncWithParam("hasRewardedAd", nullptr);
}

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideBannerUp", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideBannerDown", nullptr);
}

int AdmobProtocolAds::getBannerWidthInPixel() {
    return callIntFuncWithParam("getBannerWidthInPixel", nullptr);
}

int AdmobProtocolAds::getBannerHeightInPixel() {
    return callIntFuncWithParam("getBannerHeightInPixel", nullptr);
}
