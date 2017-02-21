//
//  GoogleProtocolAnalyticsImpl.cpp
//  PluginSenspark
//
//  Created by Zinge on 8/11/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <cassert>

#include "GoogleProtocolAnalytics.h"
#include "senspark/utility.hpp"

namespace senspark {
namespace plugin {
namespace analytics {
namespace {
/// Counts the number of character @c _ in the specified string.
constexpr std::size_t count_placeholders(const char* s, std::size_t index = 0) {
    return s[index] == '\0' ? 0 : (s[index] == '_') +
                                      count_placeholders(s, index + 1);
}

template <std::size_t Placeholders> class Parameter;

template <> class Parameter<0> {
public:
    constexpr explicit Parameter(const char* x)
        : x_(x) {
        assert(count_placeholders(x) == 0);
    }

    const char* x_;
};

template <> class Parameter<1> {
public:
    constexpr explicit Parameter(const char* x, const char* y = "")
        : x_(x)
        , y_(y) {
        assert(count_placeholders(x) == 1);
    }

    const char* x_;
    const char* y_;
};

namespace parameters {
/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
/// Required for all hit types.
/// The type of hit. Must be one of 'pageview', 'screenview', 'event',
/// 'transaction', 'item', 'social', 'exception', 'timing'.
constexpr auto hit_type = Parameter<0>("t");

namespace types {
constexpr auto event = "event";
constexpr auto screen_view = "screenview";
constexpr auto timing = "timing";
constexpr auto social = "social";
constexpr auto exception = "exception";
} // namespace types

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd
/// Required for screenview hit type.
constexpr auto screen_name = Parameter<0>("cd");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ec
/// Required for event hit type.
/// Specifies the event category. Must not be empty.
constexpr auto event_category = Parameter<0>("ec");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ea
/// Required for event hit type.
/// Specifies the event action. Must not be empty.
constexpr auto event_action = Parameter<0>("ea");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#el
/// Optional for event hit type.
/// Specifies the event label.
constexpr auto event_label = Parameter<0>("el");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ev
/// Optional for event hit type.
/// Specifies the event value. Values must be non-negative.
constexpr auto event_value = Parameter<0>("ev");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utc
/// Required for timing hit type.
/// Specifies the user timing category.
constexpr auto timing_category = Parameter<0>("utc");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utv
/// Required for timing hit type.
/// Specifies the user timing variable.
constexpr auto timing_variable_name = Parameter<0>("utv");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utt
/// Required for timing hit type.
/// Specifies the user timing value. The value is milliseconds.
constexpr auto timing_time = Parameter<0>("utt");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utl
/// Optional for timing hit type.
/// Specifies the user timing label.
constexpr auto timing_label = Parameter<0>("utl");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sn
/// Required for social hit type.
/// Specifies the social network, for example Facebook or Google Plus.
constexpr auto social_network = Parameter<0>("sn");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sa
/// Required for social hit type.
/// Specifies the social interaction action. For example on Google Plus when a
/// user clicks the +1 button, the social action is 'plus'.
constexpr auto social_action = Parameter<0>("sa");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#st
/// Required for social hit type.
/// Specifies the target of a social interaction. This value is typically a URL
/// but can be any text.
constexpr auto social_action_target = Parameter<0>("st");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exd
/// Optional for exception hit type.
/// Specifies the description of an exception.
constexpr auto exception_description = Parameter<0>("exd");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exf
/// Optional for exception hit type.
/// Specifies whether the exception was fatal.
constexpr auto is_exception_fatal = Parameter<0>("exf");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd_
/// Optional for all hit types.
/// Each custom dimension has an associated index. There is a maximum of 20
/// custom dimensions (200 for Analytics 360 accounts). The dimension index must
/// be a positive integer between 1 and 200, inclusive.
constexpr auto custom_dimension = Parameter<1>("cd_");

/// https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cm_
/// Optional for all hit types.
/// Each custom metric has an associated index. There is a maximum of 20 custom
/// metrics (200 for Analytics 360 accounts). The metric index must be a
/// positive integer between 1 and 200, inclusive.
constexpr auto custom_metric = Parameter<1>("cm_");
} // namespace parameters

std::string make_parameter(const Parameter<0>& parameter) {
    return std::string("&") + parameter.x_;
}

std::string make_parameter(const Parameter<1>& parameter, std::size_t index) {
    return std::string("&") + parameter.x_ + std::to_string(index) +
           parameter.y_;
}
} // namespace

template <class T>
T& HitBuilders::Internal<T>::set(const std::string& paramName,
                                 const std::string& paramValue) {
    dict_[paramName] = paramValue;
    return static_cast<T&>(*this);
}

template <class T>
T& HitBuilders::Internal<T>::setCustomDimenstion(std::size_t index,
                                                 const std::string& dimension) {
    return set(make_parameter(parameters::custom_dimension, index), dimension);
}

template <class T>
T& HitBuilders::Internal<T>::setCustomMetric(std::size_t index, float metric) {
    return set(make_parameter(parameters::custom_metric, index),
               std::to_string(metric));
}

template <class T>
std::map<std::string, std::string> HitBuilders::Internal<T>::build() const {
    return dict_;
}

template <class T>
T& HitBuilders::Internal<T>::setHitType(const std::string& hitType) {
    return set(make_parameter(parameters::hit_type), hitType);
}

template class HitBuilders::Internal<HitBuilders::ScreenViewBuilder>;
template class HitBuilders::Internal<HitBuilders::ExceptionBuilder>;
template class HitBuilders::Internal<HitBuilders::TimingBuilder>;
template class HitBuilders::Internal<HitBuilders::SocialBuilder>;
template class HitBuilders::Internal<HitBuilders::EventBuilder>;

HitBuilders::ScreenViewBuilder::ScreenViewBuilder() {
    setHitType(parameters::types::screen_view);
}

HitBuilders::ExceptionBuilder::ExceptionBuilder() {
    setHitType(parameters::types::exception);
}

HitBuilders::ExceptionBuilder&
HitBuilders::ExceptionBuilder::setDescription(const std::string& description) {
    return set(make_parameter(parameters::exception_description), description);
    return set(make_parameter(parameters::exception_description), description);
}

HitBuilders::ExceptionBuilder&
HitBuilders::ExceptionBuilder::setFatal(bool fatal) {
    return set(make_parameter(parameters::is_exception_fatal),
               std::to_string(fatal));
}

HitBuilders::TimingBuilder::TimingBuilder() {
    setHitType(parameters::types::timing);
}

HitBuilders::TimingBuilder&
HitBuilders::TimingBuilder::setVariable(const std::string& variable) {
    return set(make_parameter(parameters::timing_variable_name), variable);
}

HitBuilders::TimingBuilder& HitBuilders::TimingBuilder::setValue(int value) {
    return set(make_parameter(parameters::timing_time), std::to_string(value));
}

HitBuilders::TimingBuilder&
HitBuilders::TimingBuilder::setCategory(const std::string& category) {
    return set(make_parameter(parameters::timing_category), category);
}

HitBuilders::TimingBuilder&
HitBuilders::TimingBuilder::setLabel(const std::string& label) {
    return set(make_parameter(parameters::timing_label), label);
}

HitBuilders::SocialBuilder::SocialBuilder() {
    setTarget(parameters::types::social);
}

HitBuilders::SocialBuilder&
HitBuilders::SocialBuilder::setNetwork(const std::string& network) {
    return set(make_parameter(parameters::social_network), network);
}

HitBuilders::SocialBuilder&
HitBuilders::SocialBuilder::setAction(const std::string& action) {
    return set(make_parameter(parameters::social_action), action);
}

HitBuilders::SocialBuilder&
HitBuilders::SocialBuilder::setTarget(const std::string& target) {
    return set(make_parameter(parameters::social_action_target), target);
}

HitBuilders::EventBuilder::EventBuilder() {
    setHitType(parameters::types::event);
}

HitBuilders::EventBuilder&
HitBuilders::EventBuilder::setCategory(const std::string& category) {
    return set(make_parameter(parameters::event_category), category);
}

HitBuilders::EventBuilder&
HitBuilders::EventBuilder::setAction(const std::string& action) {
    return set(make_parameter(parameters::event_action), action);
}

HitBuilders::EventBuilder&
HitBuilders::EventBuilder::setLabel(const std::string& label) {
    return set(make_parameter(parameters::event_label), label);
}

HitBuilders::EventBuilder& HitBuilders::EventBuilder::setValue(int value) {
    return set(make_parameter(parameters::event_value), std::to_string(value));
}

GoogleProtocolAnalytics::GoogleProtocolAnalytics() = default;

void GoogleProtocolAnalytics::configureTracker(const std::string& trackerId) {
    callFunction(this, "configureTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::createTracker(const std::string& trackerId) {
    callFunction(this, "createTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::enableTracker(const std::string& trackerId) {
    callFunction(this, "enableTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::setLogLevel(GALogLevel logLevel) {
    callFunction(this, "setLogLevel", static_cast<int>(logLevel));
}

void GoogleProtocolAnalytics::dispatchHits() {
    callFunction(this, "dispatchHits");
}

void GoogleProtocolAnalytics::dispatchPeriodically(int seconds) {
    callFunction(this, "dispatchPeriodically", seconds);
}

void GoogleProtocolAnalytics::stopPeriodicalDispatch() {
    callFunction(this, "stopPeriodicalDispatch");
}

void GoogleProtocolAnalytics::trackScreen(const std::string& screenName) {
    setParameter(make_parameter(parameters::screen_name), screenName);
    auto builder = HitBuilders::ScreenViewBuilder();
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackEvent(const std::string& category,
                                         const std::string& action,
                                         const std::string& label, int value) {
    auto builder = HitBuilders::EventBuilder()
                       .setCategory(category)
                       .setAction(action)
                       .setLabel(label)
                       .setValue(value);
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackException(const std::string& description,
                                             bool isFatal) {
    auto builder = HitBuilders::ExceptionBuilder()
                       .setDescription(description)
                       .setFatal(isFatal);
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackTiming(const std::string& category,
                                          int interval, const std::string& name,
                                          const std::string& label) {
    auto builder = HitBuilders::TimingBuilder()
                       .setCategory(category)
                       .setValue(interval)
                       .setVariable(name)
                       .setLabel(label);
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackEcommerceTransactions(
    const std::string& identity, const std::string& productName,
    const std::string& productCategory, float priceValue) {
    callFunction(this, "trackEcommerceTransactions", identity.c_str(),
                 productName.c_str(), productCategory.c_str(), priceValue);
}

void GoogleProtocolAnalytics::trackSocial(const std::string& network,
                                          const std::string& action,
                                          const std::string& target) {
    auto builder = HitBuilders::SocialBuilder()
                       .setNetwork(network)
                       .setAction(action)
                       .setTarget(target);
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::setDryRun(bool isDryRun) {
    callFunction(this, "setDryRun", isDryRun);
}

void GoogleProtocolAnalytics::enableAdvertisingTracking(bool enable) {
    callFunction(this, "enableAdvertisingTracking", enable);
}

void GoogleProtocolAnalytics::setParameter(const std::string& key,
                                           const std::string& value) {
    callFunction(this, "setParameter", key.c_str(), value.c_str());
}

void GoogleProtocolAnalytics::sendHit(
    const std::map<std::string, std::string>& parameters) {
    callFunction(this, "sendHit", parameters);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark
