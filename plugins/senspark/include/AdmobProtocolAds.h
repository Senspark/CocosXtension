//
//  SensparkProtocolAds.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_SensparkProtocolAds_h
#define PluginSenspark_SensparkProtocolAds_h

#include "ProtocolAds.h"
#include "SensparkPluginMacros.h"
#include <string>

NS_SENSPARK_PLUGIN_ADS_BEGIN

#define GAD_SIMULATOR_ID "Simulator"

class AdmobProtocolAds : public cocos2d::plugin::ProtocolAds
{
public:
    AdmobProtocolAds();
    virtual ~AdmobProtocolAds();
    
    void configureAds(const std::string& adsId, const std::string& appPublicKey = "");
    
    void addTestDevice(const std::string& deviceId);

    void loadInterstitial();

    bool hasInterstitial();

    void slideBannerUp();
    void slideBannerDown();
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
