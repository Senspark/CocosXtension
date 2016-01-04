//
//  ChartboostProtocolAds.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_ChartboostProtocolAds_h
#define PluginSenspark_ChartboostProtocolAds_h

#include "ProtocolAds.h"

class ChartboostProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    ~ChartboostProtocolAds();
    
    void configureAds(const std::string& appID, const std::string& appSignature);
    
    bool hasMoreApps(const std::string& location);
    void showMoreApps(const std::string& location);
    void cacheMoreApps(const std::string& location);
    
    bool hasInterstitial(const std::string& location);
    void showInterstitial(const std::string& location);
    void cacheInterstitial(const std::string& location);
    
    bool hasRewardedVideo(const std::string& location);
    void showRewardedVideo(const std::string& location);
    void cacheRewardedVideo(const std::string& location);
};


#endif
