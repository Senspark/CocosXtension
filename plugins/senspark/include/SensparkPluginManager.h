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

enum class SharePluginType {
    FACEBOOK,
    GOOGLE_PLUS,
};

enum class SocialPluginType {
    FACEBOOK,
    GAME_CENTER,
    GOOGLE_PLAY,
};

enum class DataPluginType {
    GOOGLE_PLAY,
};

enum class IAPPluginType {
    GOOGLE_PLAY,
    ITUNE_STORE,
};

enum class UserPluginType {
    FACEBOOK,
    GAME_CENTER,
    GOOGLE_PLAY,
};

enum class BaaSPluginType {
    PARSE
};

template<typename T>
struct PluginTypes;

#define REGISTER_PLUGIN_TYPE(T) template <> struct PluginTypes<T> \
    {   static const char* name; \
        static std::map<T, std::string>   registeredPlugins; \
    }

#define REGISTER_PLUGIN_NAME(T, X, N) PluginTypes<T>::registeredPlugins[T::X] = N

#define PLUGIN_TYPE(X)      X ## PluginType
#define STRINGNIFY(X)   #X

#define DECLARE_PLUGIN_LOADER_METHODS(X) \
    cocos2d::plugin::PluginProtocol* load##X##Plugin(PLUGIN_TYPE(X) type); \
    void unload##X##Plugin(PLUGIN_TYPE(X) type)

#define DEFINE_PLUGIN_LOADER_METHODS(X) \
    const char* PluginTypes<PLUGIN_TYPE(X)>::name = STRINGNIFY(PLUGIN_TYPE(X)); \
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
REGISTER_PLUGIN_TYPE(BaaSPluginType);
REGISTER_PLUGIN_TYPE(DataPluginType);
REGISTER_PLUGIN_TYPE(IAPPluginType);
REGISTER_PLUGIN_TYPE(SocialPluginType);
REGISTER_PLUGIN_TYPE(SharePluginType);
REGISTER_PLUGIN_TYPE(UserPluginType);

class SensparkPluginManager {
public:
    virtual ~SensparkPluginManager();
    
    static SensparkPluginManager* getInstance();
    
    static void end();
    
    DECLARE_PLUGIN_LOADER_METHODS(Analytics);
    DECLARE_PLUGIN_LOADER_METHODS(Ads);
    DECLARE_PLUGIN_LOADER_METHODS(BaaS);
    DECLARE_PLUGIN_LOADER_METHODS(Data);
    DECLARE_PLUGIN_LOADER_METHODS(Social);
    DECLARE_PLUGIN_LOADER_METHODS(Share);
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
