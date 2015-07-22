//
//  SensparkProtocolAnalytics.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_SensparkProtocolAnalytics_h
#define PluginSenspark_SensparkProtocolAnalytics_h

#include "ProtocolAnalytics.h"
#include "SensparkPluginMacros.h"
#include <string>

using namespace std;

NS_SENSPARK_PLUGIN_BEGIN
   
class SensparkProtocolAnalytics : public cocos2d::plugin::ProtocolAnalytics {
public:
    SensparkProtocolAnalytics();
    virtual ~SensparkProtocolAnalytics();
    
    void configureTracker(const string& trackerId);
    void createTracker(const string& trackerId);
    void enableTracker(const string& trackerId);
    
    /**
     @brief Start a new session.
     @param appKey The identity of the application.
     */
    void startSession(const char* appName);
    
    /**
     @brief Stop a session.
     @warning This interface only worked on android
     */
    void stopSession();

    void setCaptureUncaughtException(bool isEnabled);
    
    void dispatchHits();
    
    void dispatchPeriodically(int seconds);
    
    void stopPeriodicalDispatch();
    
    void logScreen(const string& screenName);
    
    void logEvent(const string& category, const string& action, const string& label, float value);
    
    void logException(const string& description, bool isFatal);
    
    void logTimming(const string& category, int interval, const string& name, const string& label);
    
    void logSocial(const string& network, const string& action, const string& target);
    
    void setDryRun(bool isDryRun);
    
    void enableAdvertisingTracking(bool enable);
};

NS_SENSPARK_PLUGIN_END


#endif
