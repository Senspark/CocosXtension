//
//  ChartboostProtocolAds.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ChartboostProtocolAds.h"
#include "PluginUtilsIOS.h"

using namespace cocos2d::plugin;

ChartboostProtocolAds::~ChartboostProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void ChartboostProtocolAds::configureAds(const std::string& appID, const std::string& appSignature) {
    TAdsInfo info;
    info["ChartboostAppID"] = appID;
    info["ChartboostSignature"] = appSignature;
    PluginParam param(info);
    
    callFuncWithParam("configDeveloperInfo", &param, nullptr);
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