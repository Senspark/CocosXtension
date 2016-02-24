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
    devInfo["slideUpTimePeriod"]    = to_string(slideUpTimePeriod);
    devInfo["slideDownTimePeriod"]  = to_string(slideDownTimePeriod);
    PluginParam param(devInfo);

    PluginJavaData *pData = PluginUtils::getPluginJavaData(this);
    PluginJniMethodInfo t;
    if (PluginJniHelper::getMethodInfo(t, pData->jclassName.c_str(),
                                       "setBannerAnimationInfo", "(Ljava/util/Hashtable;)V")) {
        jobject obj_Map = PluginUtils::createJavaMapObject(&devInfo);

        t.env->CallVoidMethod(pData->jobj, t.methodID, obj_Map);
        t.env->DeleteLocalRef(obj_Map);
        t.env->DeleteLocalRef(t.classID);
    }
}

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideUpBannerAds", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideDownBannerAds", nullptr);
}
