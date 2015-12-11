//
//  GooglePlayProtocolUser.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GooglePlayProtocolUser_h
#define PluginSenspark_GooglePlayProtocolUser_h

#include "ProtocolUser.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_USER_BEGIN

#define CLIENT_NONE 0x00
#define CLIENT_GAMES 0x01
#define CLIENT_PLUS 0x02
#define CLIENT_APPSTATE 0x04
#define CLIENT_SNAPSHOT 0x08

class GooglePlayProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    GooglePlayProtocolUser();
    virtual ~GooglePlayProtocolUser();

    void configureUser(const std::string& appId);

    std::string getUserID();
    std::string getUserAvatarUrl();
    std::string getUserDisplayName();

};

NS_SENSPARK_PLUGIN_USER_END

#endif
