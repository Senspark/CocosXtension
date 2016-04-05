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

NS_SENSPARK_PLUGIN_ADS_END