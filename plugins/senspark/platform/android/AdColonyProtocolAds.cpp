#include "AdColonyProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

using namespace cocos2d::plugin;
using namespace cocos2d;

AdColonyProtocolAds::~AdColonyProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void AdColonyProtocolAds::configureAds(const std::string& appID, const std::string& zoneIDs) {
    TAdsInfo info;
    info["AdColonyAppID"]   = appID;
    info["AdColonyZoneIDs"] = zoneIDs;

    PluginParam param(info);

    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
                                       "configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&info);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
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

