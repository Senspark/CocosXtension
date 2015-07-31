//
//  GooglePlayProtocolSocial.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GooglePlayProtocolSocial.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_SOCIAL;
using namespace cocos2d::plugin;

GooglePlayProtocolSocial::GooglePlayProtocolSocial() {
    
}

GooglePlayProtocolSocial::~GooglePlayProtocolSocial() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void GooglePlayProtocolSocial::configureSocial(const std::string &appId)
{
    TSocialDeveloperInfo devInfo;
    devInfo["GoogleClientID"] = appId;
    configDeveloperInfo(devInfo);
}

void GooglePlayProtocolSocial::showLeaderboards() {
    callFuncWithParam("showLeaderboards", nullptr);
}

void GooglePlayProtocolSocial::unlockAchievement(const std::string &achievementId) {
    TAchievementInfo achievementInfo;
    achievementInfo["achievemetId"] = achievementId;
    
    ProtocolSocial::unlockAchievement(achievementInfo);
}

void GooglePlayProtocolSocial::unlockAchievement(const std::string &achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achievementInfo;
    achievementInfo["achievemetId"] = achievementId;
    
    ProtocolSocial::unlockAchievement(achievementInfo, pcb);
}

void GooglePlayProtocolSocial::revealAchievement(cocos2d::plugin::TAchievementInfo achInfo) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        callFuncWithParam("revealAchievement", &achInfoParam, nullptr);
    }
}

void GooglePlayProtocolSocial::revealAchievement(cocos2d::plugin::TAchievementInfo achInfo, GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        setCallback(pcb);
        callFuncWithParam("revealAchievement", &achInfoParam, nullptr);
    }
}

void GooglePlayProtocolSocial::revealAchievement(const std::string& achievementId) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    revealAchievement(achInfo);
}

void GooglePlayProtocolSocial::revealAchievement(const std::string& achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    revealAchievement(achInfo, pcb);
}

void GooglePlayProtocolSocial::resetAchievements() {
    callFuncWithParam("resetAchievements", nullptr);
}

void GooglePlayProtocolSocial::resetAchievements(GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    setCallback(pcb);
    resetAchievements();
}

void GooglePlayProtocolSocial::resetAchievement(cocos2d::plugin::TAchievementInfo achInfo) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        callFuncWithParam("resetAchievement", &achInfoParam, nullptr);
    }
}

void GooglePlayProtocolSocial::resetAchievement(cocos2d::plugin::TAchievementInfo achInfo, GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    
    PluginParam achInfoParam(achInfo);
    
    if (achInfo.empty()) {
        PluginUtilsIOS::outputLog("ProtocolSocial", "The achievement info is empty!");
        return;
    } else {
        setCallback(pcb);
        callFuncWithParam("resetAchievement", &achInfoParam, nullptr);
    }
}

void GooglePlayProtocolSocial::resetAchievement(const std::string& achievementId) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    resetAchievement(achInfo);
}

void GooglePlayProtocolSocial::resetAchievement(const std::string& achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb) {
    TAchievementInfo achInfo;
    achInfo["achievemetId"] = achievementId;
    
    resetAchievement(achInfo, pcb);
}


