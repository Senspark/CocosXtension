#include "AdColonyProtocolAds.h"
#include "PluginUtils.h"

using namespace cocos2d::plugin;

AdColonyProtocolAds::~AdColonyProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void AdColonyProtocolAds::configureAds(const std::string& appID, const std::string& zoneIDs) {
    TAdsInfo info;
    info["AdColonyAppID"]   = appID;
    info["AdColonyZoneIDs"] = zoneIDs;

    PluginParam param(info);

    callFuncWithParam("configDeveloperInfo", &param, nullptr);
}

bool AdColonyProtocolAds::hasInterstitial(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    return callBoolFuncWithParam("hasInterstitial", &param, nullptr);
}

void AdColonyProtocolAds::showInterstitial(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    callFuncWithParam("showInterstitial", &param, nullptr);
}

void AdColonyProtocolAds::cacheInterstitial(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    callFuncWithParam("cacheInterstitial", &param, nullptr);
}

bool AdColonyProtocolAds::hasRewardedVideo(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    return callBoolFuncWithParam("hasRewardedVideo", &param, nullptr);
}

void AdColonyProtocolAds::showRewardedVideo(const std::string &zoneID, bool isShowPrePopup, bool isShowPostPopup) {
    PluginParam param1(zoneID.c_str());
    PluginParam param2(isShowPrePopup);
    PluginParam param3(isShowPostPopup);
    callFuncWithParam("showRewardedVideo", &param1, &param2, &param3, nullptr);
}

void AdColonyProtocolAds::cacheRewardedVideo(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    callFuncWithParam("cacheRewardedVideo", &param, nullptr);
}

