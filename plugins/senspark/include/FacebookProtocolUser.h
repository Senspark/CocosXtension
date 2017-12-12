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
    enum class HttpMethod{
        GET = 0,
        POST,
        DELETE
    };
    
    typedef std::map<std::string, std::string> FBParam;
    
    FacebookProtocolUser();
    virtual ~FacebookProtocolUser();
    
    void configureUser();
    void loginWithReadPermissions(const std::string& permissions);
    void loginWithReadPermissions(const std::string& permissions, FacebookProtocolUser::UserCallback& cb);
    
    void loginWithPublishPermissions(const std::string& permissions);
    void loginWithPublishPermissions(const std::string& permissions, FacebookProtocolUser::UserCallback& cb);

    
    std::string getUserID();
    std::string getUserFullName();
    std::string getUserLastName();
    std::string getUserFirstName();
    std::string getUserAvatarUrl();
    
    void graphRequest(const std::string& graphPath, const FBParam& param, FacebookProtocolUser::UserCallback& callback);
    void api(const std::string& graphPath, HttpMethod method, const FBParam& param, FacebookProtocolUser::UserCallback& callback);

};

NS_SENSPARK_PLUGIN_USER_END

#endif
