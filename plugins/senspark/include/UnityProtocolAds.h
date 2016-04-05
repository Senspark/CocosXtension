//
//  UnityProtocolAds.h
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/4/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#ifndef UnityProtocolAds_h
#define UnityProtocolAds_h

#include "ProtocolAds.h"
#include "SensparkPluginMacros.h"

NS_SENSPARK_PLUGIN_ADS_BEGIN

class UnityProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    ~UnityProtocolAds();

    void configureAds(const std::string& appID);

    bool hasInterstitial();
    void showInterstitial();
    void cacheInterstitial();

    bool hasRewardedVideo();
    void showRewardedVideo();
};

NS_SENSPARK_PLUGIN_ADS_END

#endif /* UnityProtocolAds_h */
