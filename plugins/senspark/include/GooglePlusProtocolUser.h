//
//  GooglePlusProtocolUser.h
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/7/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#ifndef GooglePlusProtocolUser_h
#define GooglePlusProtocolUser_h

#include "ProtocolUser.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_USER_BEGIN

class GooglePlusProtocolUser : public cocos2d::plugin::ProtocolUser
{
public:
    GooglePlusProtocolUser();
    virtual ~GooglePlusProtocolUser();

    void configureUser(const std::string& appId);

    std::string getUserID();
    std::string getUserAvatarUrl();
    std::string getUserDisplayName();
};

NS_SENSPARK_PLUGIN_USER_END

#endif /* GooglePlusProtocolUser_h */
