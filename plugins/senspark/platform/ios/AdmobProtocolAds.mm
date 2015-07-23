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

USING_NS_SENSPARK_PLUGIN;
using namespace cocos2d::plugin;

AdmobProtocolAds::AdmobProtocolAds() {
    
}

AdmobProtocolAds::~AdmobProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void AdmobProtocolAds::configureAds(const std::string &bannerId, const std::string &interstitialId) {
    TAdsDeveloperInfo devInfo;
    devInfo["AdmobBannerID"] = bannerId;
    devInfo["AdmobInterstitialID"] = interstitialId;
    configDeveloperInfo(devInfo);
}

void AdmobProtocolAds::addTestDevice(const std::string &deviceId) {
    PluginParam deviceIdParam(deviceId.c_str());
    callFuncWithParam("addTestDevice", &deviceIdParam, nullptr);
}