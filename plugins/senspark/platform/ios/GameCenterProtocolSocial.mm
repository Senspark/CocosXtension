//
//  GameCenterProtocolSocial.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GameCenterProtocolSocial.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_SOCIAL;
using namespace cocos2d::plugin;

GameCenterProtocolSocial::GameCenterProtocolSocial() {
    
}

GameCenterProtocolSocial::~GameCenterProtocolSocial() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void GameCenterProtocolSocial::configureSocial()
{
}

void GameCenterProtocolSocial::unlockAchievement(const std::string &achievementId, const GameCenterProtocolSocial::SocialCallback& pcb) {
    TAchievementInfo achievementInfo;
    achievementInfo["achievementId"] = achievementId;
    achievementInfo["percent"] = 100;
    
    ProtocolSocial::unlockAchievement(achievementInfo, pcb);
}

void GameCenterProtocolSocial::revealAchievement(const std::string& achievementId, const GameCenterProtocolSocial::SocialCallback &pcb) {
    PluginParam achInfoParam(achievementId.c_str());
    
    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("revealAchievement", &achInfoParam, &callbackParam, nullptr);
}

void GameCenterProtocolSocial::resetAchievement(const std::string& achievementId, const GameCenterProtocolSocial::SocialCallback &pcb) {
    PluginParam achInfoParam(achievementId.c_str());
    
    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("resetAchievement", &achInfoParam, &callbackParam, nullptr);
}

void GameCenterProtocolSocial::resetAchievements(const GameCenterProtocolSocial::SocialCallback& pcb) {
    
    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("resetAchievements", &callbackParam, nullptr);
}
