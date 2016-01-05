//
//  AdColony.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_AdColony_h
#define PluginSenspark_AdColony_h

#include "ProtocolAds.h"

class AdColonyProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    ~AdColonyProtocolAds();

    void configureAds(const std::string& appID, const std::string& interstitialZoneID, const std::string& rewardedZoneID);

    bool hasInterstitial();
    void showInterstitial();
    void cacheInterstitial();

    bool hasRewardedVideo();
    void showRewardedVideo();
    void cacheRewardedVideo();
};

#endif
