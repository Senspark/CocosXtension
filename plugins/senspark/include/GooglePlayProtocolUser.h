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

class GooglePlayProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    GooglePlayProtocolUser();
    virtual ~GooglePlayProtocolUser();
    
    void configureUser(const std::string& appId);
};

NS_SENSPARK_PLUGIN_USER_END

#endif
