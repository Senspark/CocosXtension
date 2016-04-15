#include "UnityProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

using namespace cocos2d::plugin;
using namespace cocos2d;

NS_SENSPARK_PLUGIN_ADS_BEGIN

UnityProtocolAds::~UnityProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void UnityProtocolAds::configureAds(const std::string& appID) {
    TAdsInfo info;
    info["UnityAdsAppID"] = appID;
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

bool UnityProtocolAds::hasInterstitial(const std::string& zone) {
    PluginParam param(zone.c_str());
    return callBoolFuncWithParam("hasInterstitial", &param, nullptr);
}

void UnityProtocolAds::showInterstitial(const std::string& zone) {
    PluginParam param(zone.c_str());
    callFuncWithParam("showInterstitial", &param, nullptr);
}

void UnityProtocolAds::cacheInterstitial() {
    callFuncWithParam("cacheInterstitial", nullptr);
}

bool UnityProtocolAds::hasRewardedVideo(const std::string& zone) {
    PluginParam param(zone.c_str());
    return callBoolFuncWithParam("hasRewardedVideo", &param, nullptr);
}

void UnityProtocolAds::showRewardedVideo(const std::string& zone) {
    PluginParam param(zone.c_str());
    callFuncWithParam("showRewardedVideo", &param, nullptr);
}


NS_SENSPARK_PLUGIN_ADS_END