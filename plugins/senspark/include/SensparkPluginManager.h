//
//  SensparkPluginManager.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_SensparkPluginManager_h
#define PluginSenspark_SensparkPluginManager_h

#include "PluginProtocol.h"
#include "PluginManager.h"

#include "SensparkPluginMacros.h"

NS_SENSPARK_PLUGIN_BEGIN
    
enum class AnalyticsPluginType {
    GOOGLE_ANALYTICS,
    FLURRY_ANALYTICS,
};

enum class AdsPluginType {
    ADMOB,
    CHARTBOOST,
    FACEBOOK_ADS,
    FLURRY_ADS,
};

enum class SocialPluginType {
    
};

enum class CloudSyncPluginType {
    
};

enum class IAPPluginType {
    
};

enum class UserPluginType {
    
};
    
class SensparkPluginManager {
public:
    virtual ~SensparkPluginManager();
    
    static SensparkPluginManager* getInstance();
    
    static void end();
    
    cocos2d::plugin::PluginProtocol* loadAnalyticsPlugin(AnalyticsPluginType type);
    void unloadAnalyticsPlugin(AnalyticsPluginType type);
    
    cocos2d::plugin::PluginProtocol* loadAdsPlugin(AdsPluginType type);
    void unloadAdsPlugin(AdsPluginType type);
    
    cocos2d::plugin::PluginProtocol* loadSocialPlugin(SocialPluginType type);
    void unloadSocialPlugin(SocialPluginType type);
    
    cocos2d::plugin::PluginProtocol* loadCloudSyncPlugin(CloudSyncPluginType type);
    void unloadCloudSyncPlugin(CloudSyncPluginType type);
    
    cocos2d::plugin::PluginProtocol* loadIAPPlugin(IAPPluginType type);
    void unloadIAPPlugin(IAPPluginType type);
    
    cocos2d::plugin::PluginProtocol* loadUserPlugin(UserPluginType type);
    void unloadUserPlugin(UserPluginType type);
    
private:
    SensparkPluginManager(void);
    
    const char* getAnalyticsPluginName(AnalyticsPluginType type);
    const char* getAdsPluginName(AdsPluginType type);
    const char* getSocialPluginName(SocialPluginType type);
    const char* getCloudSyncPluginName(CloudSyncPluginType type);
    const char* getIAPPluginName(IAPPluginType type);
    const char* getUserPluginName(UserPluginType type);
    
    cocos2d::plugin::PluginManager *_cocosPluginManager;
};

NS_SENSPARK_PLUGIN_END

#endif
