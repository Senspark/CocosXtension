//
//  FacebookProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookProtocolUser.h"
#include "PluginUtilsIOS.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

FacebookProtocolUser::FacebookProtocolUser() {
    
}

FacebookProtocolUser::~FacebookProtocolUser() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void FacebookProtocolUser::configureUser() {
    TUserDeveloperInfo info;
    configDeveloperInfo(info);
}

