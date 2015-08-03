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

void GameCenterProtocolSocial::showLeaderboards() {
    callFuncWithParam("showLeaderboards", nullptr);
}

void GameCenterProtocolSocial::unlockAchievement(const std::string &achievementId) {
    TAchievementInfo achievementInfo;
    achievementInfo["achievementId"] = achievementId;
//    achievementInfo["percentComplete"] = 100;
    
    ProtocolSocial::unlockAchievement(achievementInfo);
}

void GameCenterProtocolSocial::unlockAchievement(const std::string &achievementId, GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achievementInfo;
    achievementInfo["achievemetId"] = achievementId;
//    achievementInfo["percentComplete"] = 100;
    
    ProtocolSocial::unlockAchievement(achievementInfo, pcb);
}

void GameCenterProtocolSocial::revealAchievement(cocos2d::plugin::TAchievementInfo achInfo) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        callFuncWithParam("revealAchievement", &achInfoParam, nullptr);
    }
}

void GameCenterProtocolSocial::revealAchievement(cocos2d::plugin::TAchievementInfo achInfo, GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        setCallback(pcb);
        callFuncWithParam("revealAchievement", &achInfoParam, nullptr);
    }
}

void GameCenterProtocolSocial::revealAchievement(const std::string& achievementId) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    revealAchievement(achInfo);
}

void GameCenterProtocolSocial::revealAchievement(const std::string& achievementId, GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    revealAchievement(achInfo, pcb);
}

void GameCenterProtocolSocial::resetAchievements() {
    callFuncWithParam("resetAchievements", nullptr);
}

void GameCenterProtocolSocial::resetAchievements(GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    setCallback(pcb);
    resetAchievements();
}

void GameCenterProtocolSocial::resetAchievement(cocos2d::plugin::TAchievementInfo achInfo) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        callFuncWithParam("resetAchievement", &achInfoParam, nullptr);
    }
}

void GameCenterProtocolSocial::resetAchievement(cocos2d::plugin::TAchievementInfo achInfo, GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        setCallback(pcb);
        callFuncWithParam("resetAchievement", &achInfoParam, nullptr);
    }
}

void GameCenterProtocolSocial::resetAchievement(const std::string& achievementId) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    resetAchievement(achInfo);
}

void GameCenterProtocolSocial::resetAchievement(const std::string& achievementId, GameCenterProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    resetAchievement(achInfo, pcb);
}