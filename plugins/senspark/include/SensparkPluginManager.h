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
#include <map>

NS_SENSPARK_PLUGIN_BEGIN
    
enum class AnalyticsPluginType {
    FLURRY_ANALYTICS,
    GOOGLE_ANALYTICS,
};

enum class AdsPluginType {
    ADCOLONY,
    ADMOB,
    CHARTBOOST,
    FACEBOOK_ADS,
    FLURRY_ADS,
    VUNGLE,
};

enum class SocialPluginType {
    
};

enum class CloudSyncPluginType {
    
};

enum class IAPPluginType {
    
};

enum class UserPluginType {
    GAME_CENTER,
    GOOGLE_PLAY,
};

template<typename T>
struct PluginTypes;

#define REGISTER_PLUGIN_TYPE(T) template <> struct PluginTypes<T> \
    {   static const char* name; \
        static std::map<T, std::string>   registeredPlugins; \
    }

#define REGISTER_PLUGIN_NAME(T, X, N) PluginTypes<T>::registeredPlugins[T::X] = #N

#define PLUGIN_TYPE(X)      X ## PluginType
#define STRINGNIFICATE(X)   #X

#define DECLARE_PLUGIN_LOADER_METHODS(X) \
    cocos2d::plugin::PluginProtocol* load##X##Plugin(PLUGIN_TYPE(X) type); \
    void unload##X##Plugin(PLUGIN_TYPE(X) type)

#define DEFINE_PLUGIN_LOADER_METHODS(X) \
    const char* PluginTypes<PLUGIN_TYPE(X)>::name = STRINGNIFICATE(PLUGIN_TYPE(X)); \
    \
    std::map< PLUGIN_TYPE(X), std::string> PluginTypes< PLUGIN_TYPE(X) >::registeredPlugins; \
    \
    cocos2d::plugin::PluginProtocol* SensparkPluginManager::load##X##Plugin(PLUGIN_TYPE(X) type) { \
            return _cocosPluginManager->loadPlugin(getPluginName(type)); \
    } \
    \
    void SensparkPluginManager::unload##X##Plugin(PLUGIN_TYPE(X) type) { \
        _cocosPluginManager->unloadPlugin(getPluginName(type)); \
    }

REGISTER_PLUGIN_TYPE(AnalyticsPluginType);
REGISTER_PLUGIN_TYPE(AdsPluginType);
REGISTER_PLUGIN_TYPE(SocialPluginType);
REGISTER_PLUGIN_TYPE(IAPPluginType);
REGISTER_PLUGIN_TYPE(UserPluginType);

class SensparkPluginManager {
public:
    virtual ~SensparkPluginManager();
    
    static SensparkPluginManager* getInstance();
    
    static void end();
    
    DECLARE_PLUGIN_LOADER_METHODS(Analytics);
    DECLARE_PLUGIN_LOADER_METHODS(Ads);
    DECLARE_PLUGIN_LOADER_METHODS(Social);
    DECLARE_PLUGIN_LOADER_METHODS(IAP);
    DECLARE_PLUGIN_LOADER_METHODS(User);
    
protected:
    SensparkPluginManager(void);
    
    template <typename T>
    const char* getPluginName(T type);
    
    cocos2d::plugin::PluginManager *_cocosPluginManager;
    
};

NS_SENSPARK_PLUGIN_END

#endif
