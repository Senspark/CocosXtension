//
//  VungleProtocolAds.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/24/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_VungleProtocolAds_h
#define PluginSenspark_VungleProtocolAds_h

#include "ProtocolAds.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_ADS_BEGIN

class VungleProtocolAds : public cocos2d::plugin::ProtocolAds
{
public:
    VungleProtocolAds();
    virtual ~VungleProtocolAds();
    
    void configureAds(const std::string& adsId);
    
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
