//
//  GoogleProtocolAnalytics.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GoogleProtocolAnalytics_h
#define PluginSenspark_GoogleProtocolAnalytics_h

#include "ProtocolAnalytics.h"
#include "SensparkPluginMacros.h"
#include <string>

using namespace std;

NS_SENSPARK_PLUGIN_ANALYTICS_BEGIN

enum class GALogLevel {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    VERBOSE = 4
};

class GoogleProtocolAnalytics : public cocos2d::plugin::ProtocolAnalytics {
public:
    GoogleProtocolAnalytics();
    virtual ~GoogleProtocolAnalytics();
    
    void configureTracker(const string& trackerId);
    void createTracker(const string& trackerId);
    void enableTracker(const string& trackerId);

    void setLogLevel(GALogLevel logLevel);
    
    void dispatchHits();
    
    void dispatchPeriodically(int seconds);
    
    void stopPeriodicalDispatch();
    
    void trackScreen(const string& screenName);
    
    void trackEvent(const string& category, const string& action, const string& label, float value);
    
    void trackException(const string& description, bool isFatal);
    
    void trackTimming(const string& category, int interval, const string& name, const string& label);
    
    void trackSocial(const string& network, const string& action, const string& target);
    
    void setDryRun(bool isDryRun);
    
    void enableAdvertisingTracking(bool enable);
};

NS_SENSPARK_PLUGIN_ANALYTICS_END


#endif