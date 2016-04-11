//
//  AdmobProtocolAds.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/23/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "AdmobProtocolAds.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_ADS;

using namespace cocos2d::plugin;

AdmobProtocolAds::AdmobProtocolAds() {
    
}

AdmobProtocolAds::~AdmobProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void AdmobProtocolAds::configMediationAdColony(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdColony", &pParam, nullptr);
}

void AdmobProtocolAds::configMediationAdUnity(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdUnity", &pParam, nullptr);
}

void AdmobProtocolAds::configMediationAdVungle(const cocos2d::plugin::TAdsInfo &params) {
    PluginParam pParam(params);
    callFuncWithParam("configMediationAdVungle", &pParam, nullptr);
}

void AdmobProtocolAds::configureAds(const std::string &adsId, const std::string& appPublicKey) {
    TAdsInfo devInfo;
    devInfo["AdmobID"] = adsId;
    devInfo["AppPublicKey"] = appPublicKey;
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

void AdmobProtocolAds::loadRewardedAd() {
    callFuncWithParam("loadRewardedAd", nullptr);
}

void AdmobProtocolAds::showRewardedAd() {
    callFuncWithParam("showRewardedAd", nullptr);
}

bool AdmobProtocolAds::hasRewardedAd() {
    return callBoolFuncWithParam("hasRewardedAd", nullptr);
}

void AdmobProtocolAds::slideBannerUp() {
    callFuncWithParam("slideUpBannerAds", nullptr);
}

void AdmobProtocolAds::slideBannerDown() {
    callFuncWithParam("slideDownBannerAds", nullptr);
}

int AdmobProtocolAds::getBannerWidthInPixel() {
    return callIntFuncWithParam("getBannerWidthInPixel", nullptr);
}

int AdmobProtocolAds::getBannerHeightInPixel() {
    return callIntFuncWithParam("getBannerHeightInPixel", nullptr);
}
