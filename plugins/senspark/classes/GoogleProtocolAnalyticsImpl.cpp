//
//  GoogleProtocolAnalyticsImpl.cpp
//  PluginSenspark
//
//  Created by Zinge on 8/11/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <stdio.h>

#include "GoogleProtocolAnalytics.h"

namespace senspark {
namespace plugin {
namespace analytics {
GoogleProtocolAnalytics::GoogleProtocolAnalytics() = default;

template <class... Args>
void GoogleProtocolAnalytics::callVoidFunction(const std::string& functionName,
                                               Args&&... args) {
    callVoidFunctionImpl(functionName,
                         typename SequenceGenerator<sizeof...(Args)>::Type(),
                         std::forward<Args>(args)...);
}

template <std::size_t... Indices, class... Args>
void GoogleProtocolAnalytics::callVoidFunctionImpl(
    const std::string& functionName, Sequence<Indices...>, Args&&... args) {
    using ParamType = cocos2d::plugin::PluginParam;
    std::vector<ParamType> params = {ParamType{std::forward<Args>(args)}...};
    callFuncWithParam(functionName.c_str(), &params.at(Indices)..., nullptr);
}

void GoogleProtocolAnalytics::configureTracker(const std::string& trackerId) {
    callVoidFunction("configureTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::createTracker(const std::string& trackerId) {
    callVoidFunction("createTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::enableTracker(const std::string& trackerId) {
    callVoidFunction("enableTracker", trackerId.c_str());
}

void GoogleProtocolAnalytics::setLogLevel(GALogLevel logLevel) {
    callVoidFunction("setLogLevel", static_cast<int>(logLevel));
}

void GoogleProtocolAnalytics::dispatchHits() {
    callVoidFunction("dispatchHits");
}

void GoogleProtocolAnalytics::dispatchPeriodically(int seconds) {
    callVoidFunction("dispatchPeriodically", seconds);
}

void GoogleProtocolAnalytics::stopPeriodicalDispatch() {
    callVoidFunction("stopPeriodcalDispatch");
}

void GoogleProtocolAnalytics::trackScreen(const std::string& screenName) {
    callVoidFunction("trackScreen", screenName.c_str());
}

void GoogleProtocolAnalytics::trackEvent(const std::string& category,
                                         const std::string& action,
                                         const std::string& label,
                                         float value) {
    callVoidFunction("trackEventWithCategory", category.c_str(), action.c_str(),
                     label.c_str(), value);
}

void GoogleProtocolAnalytics::trackException(const std::string& description,
                                             bool isFatal) {
    callVoidFunction("trackTimingWithCategory", description.c_str(), isFatal);
}

void GoogleProtocolAnalytics::trackTiming(const std::string& category,
                                          int interval, const std::string& name,
                                          const std::string& label) {
    callVoidFunction("trackTimingWithCategory", category.c_str(), interval,
                     name.c_str(), label.c_str());
}

void GoogleProtocolAnalytics::trackEcommerceTransactions(
    const std::string& identity, const std::string& productName,
    const std::string& productCategory, float priceValue) {
    callVoidFunction("trackEcommerceTransactions", identity.c_str(),
                     productName.c_str(), productCategory.c_str(), priceValue);
}

void GoogleProtocolAnalytics::trackSocial(const std::string& network,
                                          const std::string& action,
                                          const std::string& target) {
    callVoidFunction("trackSocialWithNetwork", network.c_str(), action.c_str(),
                     target.c_str());
}

void GoogleProtocolAnalytics::setDryRun(bool isDryRun) {
    callVoidFunction("setDryRun", isDryRun);
}

void GoogleProtocolAnalytics::enableAdvertisingTracking(bool enable) {
    callVoidFunction("enableAdvertisingTracking", enable);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark