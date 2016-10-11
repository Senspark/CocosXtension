//
//  GoogleProtocolAnalytics.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GoogleProtocolAnalytics_h
#define PluginSenspark_GoogleProtocolAnalytics_h

#include <string>

#include "ProtocolAnalytics.h"
#include "SensparkPluginMacros.h"

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

    void configureTracker(const std::string& trackerId);
    void createTracker(const std::string& trackerId);
    void enableTracker(const std::string& trackerId);

    void setLogLevel(GALogLevel logLevel);

    void dispatchHits();

    void dispatchPeriodically(int seconds);

    void stopPeriodicalDispatch();

    void trackScreen(const std::string& screenName);

    void trackEvent(const std::string& category, const std::string& action,
                    const std::string& label, float value);

    void trackException(const std::string& description, bool isFatal);

    void trackTiming(const std::string& category, int interval,
                     const std::string& name, const std::string& label);

    void trackEcommerceTransactions(const std::string& identity,
                                    const std::string& productName,
                                    const std::string& productCategory,
                                    float priceValue);

    void trackSocial(const std::string& network, const std::string& action,
                     const std::string& target);

    void setDryRun(bool isDryRun);

    void enableAdvertisingTracking(bool enable);
};

NS_SENSPARK_PLUGIN_ANALYTICS_END

#endif
