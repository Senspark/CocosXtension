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
#include "SensparkPluginMacros.h"

NS_SENSPARK_PLUGIN_ADS_BEGIN

class AdColonyProtocolAds : public cocos2d::plugin::ProtocolAds {
public:
    virtual ~AdColonyProtocolAds();

    void configureAds(const std::string& appID, const std::string& zoneIDs);

    bool hasInterstitial(const std::string& zoneID);
    void showInterstitial(const std::string& zoneID);
    void cacheInterstitial(const std::string& zoneID);

    bool hasRewardedVideo(const std::string& zoneID);
    void showRewardedVideo(const std::string& zoneID, bool isShowPrePopup, bool isShowPostPopup);
    void cacheRewardedVideo(const std::string& zoneID);
};

NS_SENSPARK_PLUGIN_ADS_END

#endif
