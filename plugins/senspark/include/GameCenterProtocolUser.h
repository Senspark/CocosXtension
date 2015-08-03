//
//  GameCenterProtocolUser.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GameCenterProtocolUser_h
#define PluginSenspark_GameCenterProtocolUser_h

#include "ProtocolUser.h"
#include "SensparkPluginMacros.h"

NS_SENSPARK_PLUGIN_USER_BEGIN

class GameCenterProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    GameCenterProtocolUser();
    virtual ~GameCenterProtocolUser();
};

NS_SENSPARK_PLUGIN_USER_END

#endif
