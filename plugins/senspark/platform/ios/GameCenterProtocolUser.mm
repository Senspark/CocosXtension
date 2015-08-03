//
//  GameCenterProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "GameCenterProtocolUser.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

GameCenterProtocolUser::GameCenterProtocolUser() {
    
}

GameCenterProtocolUser::~GameCenterProtocolUser() {
    PluginUtilsIOS::erasePluginOCData(this);
}
