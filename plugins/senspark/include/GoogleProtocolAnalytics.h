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

    /// Tracks screen.
    /// https://developers.google.com/analytics/devguides/collection/ios/v3/screens
    /// https://developers.google.com/analytics/devguides/collection/android/v4/screens
    /// Hit type: kGAIScreenView.
    void trackScreen(const std::string& screenName);

    /// Track event.
    /// https://developers.google.com/analytics/devguides/collection/ios/v3/events
    /// https://developers.google.com/analytics/devguides/collection/android/v4/events
    /// Hit type: kGAIEvent.
    void trackEvent(const std::string& category, const std::string& action,
                    const std::string& label, int value);

    /// Hit type: kGAITiming
    /// https://developers.google.com/analytics/devguides/collection/ios/v3/usertimings
    /// https://developers.google.com/analytics/devguides/collection/android/v4/usertimings
    void trackTiming(const std::string& category, int interval,
                     const std::string& name, const std::string& label);

    void trackException(const std::string& description, bool isFatal);

    void trackEcommerceTransactions(const std::string& identity,
                                    const std::string& productName,
                                    const std::string& productCategory,
                                    float priceValue);

    void trackSocial(const std::string& network, const std::string& action,
                     const std::string& target);

    void setDryRun(bool isDryRun);

    void enableAdvertisingTracking(bool enable);

    void setParameter(const std::string& key, const std::string& value);

    void sendHit(const std::map<std::string, std::string>& parameters);
};
NS_SENSPARK_PLUGIN_ANALYTICS_END

#endif
