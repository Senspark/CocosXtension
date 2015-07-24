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
USING_NS_SENSPARK_PLUGIN_ANALYTICS;

static int s_MenuCount = 5;

static EventMenuItem s_EventMenuItems[] {
    {"Log Screen", MenuItemTag::TAG_LOG_SCREEN},
    {"Log Event", MenuItemTag::TAG_LOG_EVENT},
    {"Log Timing", MenuItemTag::TAG_LOG_TIMING},
    {"Log Social", MenuItemTag::TAG_LOG_SOCIAL},
    {"Make Crash", MenuItemTag::TAG_MAKE_ME_CRASH},
};

Scene* TestGoogleAnalytics::scene() {
    Scene* scene = Scene::create();
    
    TestGoogleAnalytics *layer = TestGoogleAnalytics::create();
    
    scene->addChild(layer);
    
    return scene;
}

bool TestGoogleAnalytics::init() {
    if (!ListLayer::init())
        return false;
    
    auto pluginProtocol = SensparkPluginManager::getInstance()->loadAnalyticsPlugin(AnalyticsPluginType::GOOGLE_ANALYTICS);
    
    _pluginAnalytics = nullptr;
    _pluginAnalytics = static_cast<GoogleProtocolAnalytics*>(pluginProtocol);
    
    assert(pluginProtocol != nullptr);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    _pluginAnalytics->configureTracker(GOOGLE_ANALYTICS_KEY_IOS);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANROID) 
    _pluginAnalytics->configureTracker(GOOGLE_ANALYTICS_KEY_ANDROID);
#endif
    
    return true;
}

void TestGoogleAnalytics::onEnter() {
    ListLayer::onEnter();
    
    assert(_pluginAnalytics != nullptr);
    
    _pluginAnalytics->dispatchPeriodically(20);
    _pluginAnalytics->setDryRun(false);
    _pluginAnalytics->enableAdvertisingTracking(true);
    _pluginAnalytics->setCaptureUncaughtException(true);
    _pluginAnalytics->setLogLevel(GALogLevel::VERBOSE);
    
    _pluginAnalytics->startSession(APP_NAME);
    
    const char* sdkVer = _pluginAnalytics->getSDKVersion().c_str();
    log("SDK Version : %s", sdkVer);
    
    for (int i = 0; i < s_MenuCount; i++) {
        addTest(s_EventMenuItems[i].title, [this, i]() -> void {
            this->doAction(s_EventMenuItems[i].tag);
        });
    }
}

void TestGoogleAnalytics::onExit() {
    ListLayer::onExit();
    
    assert(_pluginAnalytics != nullptr);
    

    _pluginAnalytics->stopSession();
    
    SensparkPluginManager::getInstance()->unloadAnalyticsPlugin(AnalyticsPluginType::GOOGLE_ANALYTICS);
    _pluginAnalytics = nullptr;
}

void TestGoogleAnalytics::doAction(MenuItemTag tag) {
    switch (tag) {
        case MenuItemTag::TAG_LOG_SCREEN:
            log("Send log screen event.");
            _pluginAnalytics->trackScreen("TestScreen");
            break;
        case MenuItemTag::TAG_LOG_EVENT:
            log("Send log event");
            _pluginAnalytics->trackEvent("TestCategory", "TestAction", "TestLabel", 1);
            break;
        case MenuItemTag::TAG_LOG_TIMING:
            log("Send log timming");
            _pluginAnalytics->trackTimming("TestTimming", 1, "TimmingName", "TimminLabel");
            break;
        case MenuItemTag::TAG_LOG_SOCIAL:
            log("Send log social");
            _pluginAnalytics->trackSocial("TestSocialNetwork", "SocialAction", "SocialTarget");
            break;
        case MenuItemTag::TAG_MAKE_ME_CRASH:
            {
                char* pNull = NULL;
                *pNull = 0;
            }
            break;
    }
}