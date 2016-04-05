#include "AdColonyProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

using namespace cocos2d::plugin;
using namespace cocos2d;

NS_SENSPARK_PLUGIN_ADS_BEGIN

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
    TAdsInfo info;
    info["Param1"] = zoneID;
    info["Param2"] = isShowPrePopup;
    info["Param3"] = isShowPostPopup;

    PluginParam param(info);

    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
                                       "showRewardedVideo", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&info);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}

void AdColonyProtocolAds::cacheRewardedVideo(const std::string& zoneID) {
    PluginParam param(zoneID.c_str());
    callFuncWithParam("cacheRewardedVideo", &param, nullptr);
}

NS_SENSPARK_PLUGIN_ADS_END