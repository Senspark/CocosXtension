//
//  ParseProtocolBaaS.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/17/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_ParseProtocolBaaS_h
#define PluginSenspark_ParseProtocolBaaS_h

#include "ProtocolBaaS.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_BAAS_BEGIN

class ParseProtocolBaaS : public cocos2d::plugin::ProtocolBaaS
{
public:
    ParseProtocolBaaS();
    virtual ~ParseProtocolBaaS();
};

NS_SENSPARK_PLUGIN_BAAS_END

#endif
