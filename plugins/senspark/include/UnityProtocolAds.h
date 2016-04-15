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

    bool hasInterstitial(const std::string& zone);
    void showInterstitial(const std::string& zone);
    void cacheInterstitial();

    bool hasRewardedVideo(const std::string& zone);
    void showRewardedVideo(const std::string& zone);
};

NS_SENSPARK_PLUGIN_ADS_END

#endif /* UnityProtocolAds_h */
