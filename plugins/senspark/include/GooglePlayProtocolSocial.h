//
//  GooglePlayProtocolSocial.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GooglePlayProtocolSocial_h
#define PluginSenspark_GooglePlayProtocolSocial_h

#include "ProtocolSocial.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_SOCIAL_BEGIN

class GooglePlayProtocolSocial : public cocos2d::plugin::ProtocolSocial
{
public:
    GooglePlayProtocolSocial();
    virtual ~GooglePlayProtocolSocial();
    
    void configureSocial(const std::string& appId);
    void showLeaderboards();
    
    void unlockAchievement(const std::string& achievementId);
    void unlockAchievement(const std::string& achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
    
    void revealAchievement(cocos2d::plugin::TAchievementInfo achInfo);
    void revealAchievement(cocos2d::plugin::TAchievementInfo achInfo, GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
    void revealAchievement(const std::string& achievementId);
    void revealAchievement(const std::string& achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
    
    void resetAchievement(cocos2d::plugin::TAchievementInfo achInfo);
    void resetAchievement(cocos2d::plugin::TAchievementInfo achInfo, GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
    void resetAchievement(const std::string& achievementId);
    void resetAchievement(const std::string& achievementId, GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
    
    void resetAchievements();
    void resetAchievements(GooglePlayProtocolSocial::ProtocolSocialCallback pcb);
};

NS_SENSPARK_PLUGIN_SOCIAL_END
#endif
