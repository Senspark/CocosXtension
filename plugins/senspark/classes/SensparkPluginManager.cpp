//
//  SensparkPluginManager.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "SensparkPluginManager.h"

using namespace senspark::plugin;
using namespace cocos2d::plugin;
using namespace std;

static SensparkPluginManager* s_pPluginManager = nullptr;

DEFINE_PLUGIN_LOADER_METHODS(Analytics);
DEFINE_PLUGIN_LOADER_METHODS(Ads);
DEFINE_PLUGIN_LOADER_METHODS(Data);
DEFINE_PLUGIN_LOADER_METHODS(Social);
DEFINE_PLUGIN_LOADER_METHODS(IAP);
DEFINE_PLUGIN_LOADER_METHODS(User);
DEFINE_PLUGIN_LOADER_METHODS(BaaS);
DEFINE_PLUGIN_LOADER_METHODS(Share);

SensparkPluginManager::SensparkPluginManager(void)
{
    _cocosPluginManager = PluginManager::getInstance();
    
    //------ Register Analytics Services -------
    REGISTER_PLUGIN_NAME(AnalyticsPluginType, FLURRY_ANALYTICS, "AnalyticsFlurry");
    REGISTER_PLUGIN_NAME(AnalyticsPluginType, GOOGLE_ANALYTICS, "AnalyticsGoogle");
    
    //------ Register Ads Services -------
    REGISTER_PLUGIN_NAME(AdsPluginType, ADMOB, "AdsAdmob");
    REGISTER_PLUGIN_NAME(AdsPluginType, ADCOLONY, "AdsAdColony");
    REGISTER_PLUGIN_NAME(AdsPluginType, CHARTBOOST, "AdsChartboost");
    REGISTER_PLUGIN_NAME(AdsPluginType, FACEBOOK_ADS, "AdsFacebook");
    REGISTER_PLUGIN_NAME(AdsPluginType, FLURRY_ADS, "AdsFlurry");
    REGISTER_PLUGIN_NAME(AdsPluginType, VUNGLE, "AdsVungle");
    
    //------ Register BaaS Services ------
    REGISTER_PLUGIN_NAME(BaaSPluginType, PARSE, "BaaSParse");
    REGISTER_PLUGIN_NAME(BaaSPluginType, BAASBOX, "PluginBaasbox");
    
    //------ Register Data Services ------
    REGISTER_PLUGIN_NAME(DataPluginType, GOOGLE_PLAY, "DataGooglePlay");
    
    //------ Register Social Services
    REGISTER_PLUGIN_NAME(SocialPluginType, FACEBOOK, "SocialFacebook");
    REGISTER_PLUGIN_NAME(SocialPluginType, GAME_CENTER, "SocialGameCenter");
    REGISTER_PLUGIN_NAME(SocialPluginType, GOOGLE_PLAY, "SocialGooglePlay");
    
    //------ Register User Service ------
    REGISTER_PLUGIN_NAME(UserPluginType, FACEBOOK, "UserFacebook");
    REGISTER_PLUGIN_NAME(UserPluginType, GAME_CENTER, "UserGameCenter");
    REGISTER_PLUGIN_NAME(UserPluginType, GOOGLE_PLAY, "UserGooglePlay");

    //------ Register Share Serice ------
    REGISTER_PLUGIN_NAME(SharePluginType, FACEBOOK, "ShareFacebook");
    REGISTER_PLUGIN_NAME(SharePluginType, GOOGLE_PLUS, "ShareGooglePlus");

}

SensparkPluginManager::~SensparkPluginManager(void)
{
    if (_cocosPluginManager != nullptr) {
        _cocosPluginManager->end();
        _cocosPluginManager = nullptr;
    }
}

SensparkPluginManager* SensparkPluginManager::getInstance()
{
    if (s_pPluginManager == nullptr) {
        s_pPluginManager = new SensparkPluginManager();
    }
    
    return s_pPluginManager;
}

void SensparkPluginManager::end()
{
    if (s_pPluginManager != nullptr) {
        delete s_pPluginManager;
        s_pPluginManager = nullptr;
    }
}

template <typename T>
const char* SensparkPluginManager::getPluginName(T type) {
    const char* name = nullptr;
    auto got = PluginTypes<T>::registeredPlugins.find(type);
    if (got != PluginTypes<T>::registeredPlugins.end())
        name = got->second.c_str();
    
    return name;
}
