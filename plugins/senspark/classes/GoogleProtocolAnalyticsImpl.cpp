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
namespace parameters {
constexpr auto hit_type = "t"; /// Required for all hit types.

namespace types {
constexpr auto event = "event";
constexpr auto screen_view = "screenview";
constexpr auto timing = "timing";
constexpr auto social = "social";
constexpr auto exception = "exception";
} // namespace types

constexpr auto screen_name = "cd";

constexpr auto event_category = "ec"; ///< Required for event hit type.
constexpr auto event_action = "ea";   ///< Required for event hit type.
constexpr auto event_label = "el";    ///< Optional for event hit type.
constexpr auto event_value = "ev";    ///< Optional for event hit type.

constexpr auto timing_category = "utc";      ///< Required for timing hit type.
constexpr auto timing_variable_name = "utv"; ///< Required for timing hit type.
constexpr auto timing_time = "utt";          ///< Required for timing hit type.
constexpr auto timing_label = "utl";         /// Optional for timing hit type.

constexpr auto social_network = "sn";       ///< Required for social hit type.
constexpr auto social_action = "sa";        ///< Required for social hit type.
constexpr auto social_action_target = "st"; ///< Required for social hit type.

constexpr auto exception_description =
    "exd";                                 ///< Optional for exception hit type.
constexpr auto is_exception_fatal = "exf"; ///< Optional for exception hit type.
} // namespace parameters

std::string make_parameter(const std::string& parameter) {
    return "&" + parameter;
}
} // namespace

template <class T>
T& HitBuilders::Internal<T>::set(const std::string& paramName,
                                 const std::string& paramValue) {
    dict_[paramName] = paramValue;
    return static_cast<T&>(*this);
}

template <class T>
T& HitBuilders::Internal<T>::setCustomDimenstion(int index,
                                                 const std::string& dimension) {
    // FIXME.
    return static_cast<T&>(*this);
}

template <class T>
T& HitBuilders::Internal<T>::setCustomMetric(int index, float metric) {
    // FIXME.
    return static_cast<T&>(*this);
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
