//
//  GooglePlayProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/28/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GooglePlayProtocolUser.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

GooglePlayProtocolUser::GooglePlayProtocolUser() {
    
}

GooglePlayProtocolUser::~GooglePlayProtocolUser() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void GooglePlayProtocolUser::configureUser(const std::string &appId) {
    TUserInfo devInfo;
    devInfo["GoogleClientID"] = appId;
    configDeveloperInfo(devInfo);
}


