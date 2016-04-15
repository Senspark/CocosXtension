//
//  UnityProtocolAds.mm
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/5/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnityProtocolAds.h"
#import "PluginUtilsIOS.h"

using namespace cocos2d::plugin;

NS_SENSPARK_PLUGIN_ADS_BEGIN

UnityProtocolAds::~UnityProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void UnityProtocolAds::configureAds(const std::string& appID) {
    TAdsInfo info;
    info["UnityAdsAppID"] = appID;
    PluginParam param(info);

    callFuncWithParam("configDeveloperInfo", &param, nullptr);
}

bool UnityProtocolAds::hasInterstitial(const std::string &zone) {
    PluginParam param(zone.c_str());
    return callBoolFuncWithParam("hasInterstitial", &param, nullptr);
}

void UnityProtocolAds::showInterstitial(const std::string &zone) {
    PluginParam param(zone.c_str());
    callFuncWithParam("showInterstitial", &param, nullptr);
}

void UnityProtocolAds::cacheInterstitial() {
    callFuncWithParam("cacheInterstitial", nullptr);
}

bool UnityProtocolAds::hasRewardedVideo(const std::string &zone) {
    PluginParam param(zone.c_str());
    return callBoolFuncWithParam("hasRewardedVideo", &param, nullptr);
}

void UnityProtocolAds::showRewardedVideo(const std::string &zone) {
    PluginParam param(zone.c_str());
    callFuncWithParam("showRewardedVideo", &param, nullptr);
}

NS_SENSPARK_PLUGIN_ADS_END