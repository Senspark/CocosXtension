//
//  AdColonyProtocolAds.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AdColonyProtocolAds.h"
#include "PluginUtilsIOS.h"

using namespace cocos2d::plugin;

AdColonyProtocolAds::~AdColonyProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void AdColonyProtocolAds::configureAds(const std::string& appID, const std::string& interstitialZoneID, const std::string& rewardedZoneID) {
    TAdsInfo info;
    info["AdColonyAppID"]                = appID;
    info["AdColonyRewardedAdZoneID"]     = rewardedZoneID;
    info["AdColonyInterstitialAdZoneID"] = interstitialZoneID;
    PluginParam param(info);

    callFuncWithParam("configDeveloperInfo", &param, nullptr);
}

bool AdColonyProtocolAds::hasInterstitial() {
    return callBoolFuncWithParam("hasInterstitial", nullptr);
}

void AdColonyProtocolAds::showInterstitial() {
    callFuncWithParam("showInterstitial", nullptr);
}

void AdColonyProtocolAds::cacheInterstitial() {
    callFuncWithParam("cacheInterstitial", nullptr);
}

bool AdColonyProtocolAds::hasRewardedVideo() {
    return callBoolFuncWithParam("hasRewardedVideo", nullptr);
}

void AdColonyProtocolAds::showRewardedVideo() {
    callFuncWithParam("showRewardedVideo", nullptr);
}

void AdColonyProtocolAds::cacheRewardedVideo() {
    callFuncWithParam("cacheRewardedVideo", nullptr);
}

