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

static SensparkPluginManager* s_pPluginManager = nullptr;

SensparkPluginManager::SensparkPluginManager(void)
{
    _cocosPluginManager = PluginManager::getInstance();
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

PluginProtocol* SensparkPluginManager::loadAnalyticsPlugin(AnalyticsPluginType type) {
    return _cocosPluginManager->loadPlugin(getAnalyticsPluginName(type));
}

void SensparkPluginManager::unloadAnalyticsPlugin(AnalyticsPluginType type) {
    _cocosPluginManager->unloadPlugin(getAnalyticsPluginName(type));
}

PluginProtocol* SensparkPluginManager::loadAdsPlugin(AdsPluginType type) {
    return _cocosPluginManager->loadPlugin(getAdsPluginName(type));
}

void SensparkPluginManager::unloadAdsPlugin(AdsPluginType type) {
    _cocosPluginManager->unloadPlugin(getAdsPluginName(type));
}

PluginProtocol* SensparkPluginManager::loadCloudSyncPlugin(CloudSyncPluginType type) {
    return _cocosPluginManager->loadPlugin(getCloudSyncPluginName(type));
}

void SensparkPluginManager::unloadCloudSyncPlugin(CloudSyncPluginType type) {
    _cocosPluginManager->unloadPlugin(getCloudSyncPluginName(type));
}

PluginProtocol* SensparkPluginManager::loadIAPPlugin(IAPPluginType type) {
    return _cocosPluginManager->loadPlugin(getIAPPluginName(type));
}

void SensparkPluginManager::unloadIAPPlugin(IAPPluginType type) {
    _cocosPluginManager->unloadPlugin(getIAPPluginName(type));
}

PluginProtocol* SensparkPluginManager::loadSocialPlugin(SocialPluginType type) {
    return _cocosPluginManager->loadPlugin(getSocialPluginName(type));
}

void SensparkPluginManager::unloadSocialPlugin(SocialPluginType type) {
    _cocosPluginManager->unloadPlugin(getSocialPluginName(type));
}

PluginProtocol* SensparkPluginManager::loadUserPlugin(UserPluginType type) {
    return _cocosPluginManager->loadPlugin(getUserPluginName(type));
}

void SensparkPluginManager::unloadUserPlugin(UserPluginType type) {
    _cocosPluginManager->unloadPlugin(getUserPluginName(type));
}

const char* SensparkPluginManager::getAnalyticsPluginName(AnalyticsPluginType type) {
    const char* name = nullptr;
    
    switch (type) {
        case AnalyticsPluginType::FLURRY_ANALYTICS:
            name = "AnalyticsFlurry";
            break;
        case AnalyticsPluginType::GOOGLE_ANALYTICS:
            name = "AnalyticsGoogle";
            break;
    }
    
    return name;
}

const char* SensparkPluginManager::getAdsPluginName(AdsPluginType type) {
    const char* name = nullptr;
    return name;
}

const char* SensparkPluginManager::getSocialPluginName(SocialPluginType type) {
    const char* name = nullptr;
    return name;
}

const char* SensparkPluginManager::getCloudSyncPluginName(CloudSyncPluginType type) {
    const char* name = nullptr;
    return name;
}

const char* SensparkPluginManager::getIAPPluginName(IAPPluginType type) {
    const char* name = nullptr;
    return name;
}

const char* SensparkPluginManager::getUserPluginName(UserPluginType type) {
    const char* name = nullptr;
    return name;
}

