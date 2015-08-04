//
//  FacebookProtocolUser.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_FacebookProtocolUser_h
#define PluginSenspark_FacebookProtocolUser_h

#include "ProtocolUser.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_USER_BEGIN

class FacebookProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    FacebookProtocolUser();
    virtual ~FacebookProtocolUser();
    
    void configureUser();
    void loginWithPermissions(const std::string& permissions);
    void loginWithPermissions(const std::string& permissions, FacebookProtocolUser::ProtocolUserCallback& cb);
    std::string getUserID();
    
};

NS_SENSPARK_PLUGIN_USER_END

#endif
