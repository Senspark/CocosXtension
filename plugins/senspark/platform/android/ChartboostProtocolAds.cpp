#include "ChartboostProtocolAds.h"
#include "PluginUtils.h"
#include "PluginJniHelper.h"

using namespace cocos2d::plugin;
using namespace cocos2d;

ChartboostProtocolAds::~ChartboostProtocolAds() {
    PluginUtils::erasePluginJavaData(this);
}

void ChartboostProtocolAds::configureAds(const std::string& appID, const std::string& appSignature) {
    TAdsInfo devInfo;
    devInfo["ChartboostAppId"] = appID;
    devInfo["ChartboostAppSignature"] = appSignature;
    PluginParam param(devInfo);

    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
                                       "configDeveloperInfo", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }

}

bool ChartboostProtocolAds::hasMoreApps(const std::string& location) {
    PluginParam param(location.c_str());
    return callBoolFuncWithParam("hasMoreApps", &param, nullptr);
}

void ChartboostProtocolAds::showMoreApps(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("showMoreApps", &param, nullptr);
}

void ChartboostProtocolAds::cacheMoreApps(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("cacheMoreApps", &param, nullptr);
}

bool ChartboostProtocolAds::hasInterstitial(const std::string& location) {
    PluginParam param(location.c_str());
    return callBoolFuncWithParam("hasInterstitial", &param, nullptr);
}

void ChartboostProtocolAds::showInterstitial(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("showInterstitial", &param, nullptr);
}

void ChartboostProtocolAds::cacheInterstitial(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("cacheInterstitial", &param, nullptr);
}

bool ChartboostProtocolAds::hasRewardedVideo(const std::string& location) {
    PluginParam param(location.c_str());
    return callBoolFuncWithParam("hasRewardedVideo", &param, nullptr);
}

void ChartboostProtocolAds::showRewardedVideo(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("showRewardedVideo", &param, nullptr);
}

void ChartboostProtocolAds::cacheRewardedVideo(const std::string& location) {
    PluginParam param(location.c_str());
    return callFuncWithParam("cacheRewardedVideo", &param, nullptr);
}
