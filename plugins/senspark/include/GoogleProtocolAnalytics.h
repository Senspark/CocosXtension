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

class HitBuilders {
private:
    /// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.HitBuilder
    /// Internal class to provide common builder class methods. The most
    /// important methods from this class are the setXYZ and build methods.
    /// These methods can be used to set individual properties on the hit and
    /// then build it so that it is ready to be passed into the tracker.
    template <class T> class Internal {
    public:
        /// Sets the value for the given parameter name.
        /// @param paramName The name of the parameter that should be sent over
        /// wire. This value should start with "&".
        /// @param paramValue The value to be sent over the wire for the given
        /// parameter.
        T& set(const std::string& paramName, const std::string& paramValue);

        /// Adds a custom dimension to the current hit builder. Calling this
        /// method with the same index will overwrite the previous dimension
        /// with the new one.
        /// @param index The index/slot in which the dimension will be set.
        /// @param dimension The value of the dimension for the given index.
        T& setCustomDimenstion(std::size_t index, const std::string& dimension);

        /// Adds a custom metric to the current hit builder. Calling this method
        /// with the same index will overwrite the previous metric with the new
        /// one.
        /// @param index The index/slot in which the dimension will be set.
        /// @param metric The value of the metric for the given index.
        T& setCustomMetric(std::size_t index, float metric);

        /// Builds a Map of parameters and values that can be set on the Tracker
        /// object.
        /// @return A map of string keys to string values that can be passed
        /// into the tracker for one or more hits.
        std::map<std::string, std::string> build() const;

    protected:
        /// Sets the type of the hit to be sent. This can be used to reuse the
        /// builder object for multiple hit types.
        /// @param hitType The value of the Hit.
        T& setHitType(const std::string& hitType);

    private:
        std::map<std::string, std::string> dict_;
    };

public:
    class ScreenViewBuilder : public Internal<ScreenViewBuilder> {
    public:
        ScreenViewBuilder();
    };

    class ExceptionBuilder : public Internal<ExceptionBuilder> {
    public:
        ExceptionBuilder();
        ExceptionBuilder& setDescription(const std::string& description);
        ExceptionBuilder& setFatal(bool fatal);
    };

    class TimingBuilder : public Internal<TimingBuilder> {
    public:
        TimingBuilder();
        TimingBuilder& setVariable(const std::string& variable);
        TimingBuilder& setValue(int value);
        TimingBuilder& setCategory(const std::string& category);
        TimingBuilder& setLabel(const std::string& label);
    };

    class SocialBuilder : public Internal<SocialBuilder> {
    public:
        SocialBuilder();
        SocialBuilder& setNetwork(const std::string& network);
        SocialBuilder& setAction(const std::string& action);
        SocialBuilder& setTarget(const std::string& target);
    };

    class EventBuilder : public Internal<EventBuilder> {
    public:
        EventBuilder();
        EventBuilder& setCategory(const std::string& category);
        EventBuilder& setAction(const std::string& action);
        EventBuilder& setLabel(const std::string& label);
        EventBuilder& setValue(int value);
    };
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
