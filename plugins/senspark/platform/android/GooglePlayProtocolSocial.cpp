//
//  GooglePlayProtocolSocial.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "GooglePlayProtocolSocial.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_SOCIAL;
using namespace cocos2d::plugin;

GooglePlayProtocolSocial::GooglePlayProtocolSocial() {

}

GooglePlayProtocolSocial::~GooglePlayProtocolSocial() {
    PluginUtils::erasePluginJavaData(this);
}

void GooglePlayProtocolSocial::configureSocial(const std::string &appId)
{
    TSocialInfo devInfo;
    devInfo["GoogleClientID"] = appId;
    configDeveloperInfo(devInfo);
}

void GooglePlayProtocolSocial::unlockAchievement(const std::string &achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb) {

    TAchievementInfo achievementInfo;
    achievementInfo["achievementId"] = achievementId;
    achievementInfo["percent"] = 100;

    ProtocolSocial::unlockAchievement(achievementInfo, pcb);
}

void GooglePlayProtocolSocial::revealAchievement(const std::string& achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb) {
    PluginParam idParam(achievementId.c_str());

    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam cbParam((long long) wrapper);

    callFuncWithParam("revealAchievement", &idParam, &cbParam, nullptr);
}

void GooglePlayProtocolSocial::resetAchievement(const std::string& achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb) {
    PluginParam idParam(achievementId.c_str());

    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam cbParam((long long) wrapper);

    callFuncWithParam("resetAchievement", &idParam, &cbParam, nullptr);
}

void GooglePlayProtocolSocial::resetAchievements(const GooglePlayProtocolSocial::SocialCallback& pcb) {

    CallbackWrapper* wrapper = new CallbackWrapper(pcb);
    PluginParam cbParam((long long) wrapper);


    callFuncWithParam("resetAchievements", &cbParam, nullptr);
}
