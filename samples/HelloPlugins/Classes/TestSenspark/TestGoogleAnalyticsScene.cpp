//
//  TestGoogleAnalyticsScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/20/15.
//
//

#include "TestGoogleAnalyticsScene.h"
#include "ProtocolAnalytics.h"

USING_NS_SENSPARK;
USING_NS_SENSPARK_PLUGIN;

Scene* TestGoogleAnalytics::scene() {
    Scene* scene = Scene::create();
    
    TestGoogleAnalytics *layer = TestGoogleAnalytics::create();
    
    scene->addChild(layer);
    
    return scene;
}

bool TestGoogleAnalytics::init() {
    if (!Layer::init())
        return false;
    
    auto pluginProtocol = SensparkPluginManager::getInstance()->loadAnalyticsPlugin(AnalyticsPluginType::GOOGLE_ANALYTICS);
    
    _pluginAnalytics = nullptr;
    _pluginAnalytics = static_cast<SensparkProtocolAnalytics*>(pluginProtocol);
    
    assert(pluginProtocol != nullptr);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    _pluginAnalytics->configureTracker(GOOGLE_ANALYTICS_KEY_IOS);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANROID) 
    _pluginAnalytics->configureTracker(GOOGLE_ANALYTICS_KEY_ANDROID);
#endif
    
    _pluginAnalytics->startSession(APP_NAME);
    _pluginAnalytics->setDryRun(true);
    _pluginAnalytics->enableAdvertisingTracking(true);
    _pluginAnalytics->setCaptureUncaughtException(true);
    
    const char* sdkVer = _pluginAnalytics->getSDKVersion().c_str();
    log("SDK Version : %s", sdkVer);
    
    return true;
}

void TestGoogleAnalytics::onExit() {
    Layer::onExit();
    
    if (nullptr != _pluginAnalytics) {
        _pluginAnalytics->stopSession();
        
        SensparkPluginManager::getInstance()->unloadAnalyticsPlugin(AnalyticsPluginType::GOOGLE_ANALYTICS);
        _pluginAnalytics = nullptr;
    }
}
