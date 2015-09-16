//
//  FacebookProtocolShare.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_FacebookProtocolShare_h
#define PluginSenspark_FacebookProtocolShare_h

#include "ProtocolShare.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_SHARE_BEGIN

class FacebookProtocolShare : public cocos2d::plugin::ProtocolShare
{
public:
    FacebookProtocolShare();
    virtual ~FacebookProtocolShare();
};

NS_SENSPARK_PLUGIN_SHARE_END

#endif
