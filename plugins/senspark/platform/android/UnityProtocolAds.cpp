#include "UnityProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

using namespace cocos2d::plugin;
using namespace cocos2d;

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

bool UnityProtocolAds::hasInterstitial() {
    return callBoolFuncWithParam("hasInterstitial", nullptr);
}

void UnityProtocolAds::showInterstitial() {
    callFuncWithParam("showInterstitial", nullptr);
}

void UnityProtocolAds::cacheInterstitial() {
    callFuncWithParam("cacheInterstitial", nullptr);
}

bool UnityProtocolAds::hasRewardedVideo() {
    return callBoolFuncWithParam("hasRewardedVideo", nullptr);
}

void UnityProtocolAds::showRewardedVideo() {
    callFuncWithParam("showRewardedVideo", nullptr);
}
