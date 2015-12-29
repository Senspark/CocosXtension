//
//  GameCenterProtocolSocial.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GameCenterProtocolSocial_h
#define PluginSenspark_GameCenterProtocolSocial_h

#include "ProtocolSocial.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_SOCIAL_BEGIN

class GameCenterProtocolSocial : public cocos2d::plugin::ProtocolSocial
{
public:
    GameCenterProtocolSocial();
    virtual ~GameCenterProtocolSocial();
    
    void configureSocial();
    void showLeaderboards();
    
    void unlockAchievement(const std::string& achievementId, const GameCenterProtocolSocial::SocialCallback &pcb);

    void revealAchievement(const std::string& achievementId, const GameCenterProtocolSocial::SocialCallback& pcb);

    void resetAchievement(const std::string& achievementId, const GameCenterProtocolSocial::SocialCallback& pcb);
    

    void resetAchievements(const GameCenterProtocolSocial::SocialCallback &pcb);
};

NS_SENSPARK_PLUGIN_SOCIAL_END
#endif

