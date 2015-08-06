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
#include "FacebookAgent.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_USER_BEGIN

class FacebookProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    typedef cocos2d::plugin::FacebookAgent::FBParam FBParam;
    typedef cocos2d::plugin::FacebookAgent::FBCallback FBCallback;
    
    FacebookProtocolUser();
    virtual ~FacebookProtocolUser();
    
    void configureUser();
    void loginWithReadPermissions(const std::string& permissions);
    void loginWithReadPermissions(const std::string& permissions, FacebookProtocolUser::ProtocolUserCallback& cb);
    
    void loginWithPublishPermissions(const std::string& permissions);
    void loginWithPublishPermissions(const std::string& permissions, FacebookProtocolUser::ProtocolUserCallback& cb);

    
    std::string getUserID();
    void graphRequest(const std::string& graphPath, const FBParam& param, FBCallback& callback);
    void api(const std::string& graphPath, int method, const FBParam& param, FBCallback& callback);
};

NS_SENSPARK_PLUGIN_USER_END

#endif
