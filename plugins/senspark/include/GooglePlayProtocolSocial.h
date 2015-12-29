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
    
    void unlockAchievement(const std::string& achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb);
    
    void revealAchievement(const std::string& achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb);
    
    void resetAchievement(const std::string& achievementId, const GooglePlayProtocolSocial::SocialCallback& pcb);
    
    void resetAchievements(const GooglePlayProtocolSocial::SocialCallback& pcb);
};

NS_SENSPARK_PLUGIN_SOCIAL_END
#endif
