//
//  VungleProtocolAds.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/24/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "VungleProtocolAds.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_ADS;

using namespace cocos2d::plugin;

VungleProtocolAds::VungleProtocolAds() {
    
}

VungleProtocolAds::~VungleProtocolAds() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void VungleProtocolAds::configureAds(const std::string &adsId) {
    TAdsInfo devInfo;
    devInfo["VungleID"] = adsId;
    configDeveloperInfo(devInfo);
}
