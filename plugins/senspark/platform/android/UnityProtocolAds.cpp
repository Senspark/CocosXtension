#include "UnityProtocolAds.h"
#include "PluginUtils.h"

using namespace cocos2d::plugin;

UnityProtocolAds::~UnityProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void UnityProtocolAds::configureAds(const std::string& appID) {
    TAdsInfo info;
    info["UnityAdsAppID"] = appID;
    PluginParam param(info);

    callFuncWithParam("configDeveloperInfo", &param, nullptr);
}

bool UnityProtocolAds::hasInterstitial() {
    return callBoolFuncWithParam("hasInterstitial", nullptr);
}

void UnityProtocolAds::showInterstitial() {
    callFuncWithParam("showInterstitial", nullptr);
}

void UnityProtocolAds::cacheInterstitial() {
    callFuncWithParam("cacheInterstitial", nullptr);
}
