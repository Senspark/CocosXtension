//
//  GoogleProtocolAnalyticsImpl.cpp
//  PluginSenspark
//
//  Created by Zinge on 8/11/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#include <stdio.h>

#include "GoogleProtocolAnalytics.h"
#include "senspark/utility.hpp"

namespace senspark {
namespace plugin {
namespace analytics {
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
    callFunction(this, "stopPeriodcalDispatch");
}

void GoogleProtocolAnalytics::trackScreen(const std::string& screenName) {
    callFunction(this, "trackScreen", screenName.c_str());
}

void GoogleProtocolAnalytics::trackEvent(const std::string& category,
                                         const std::string& action,
                                         const std::string& label,
                                         float value) {
    callFunction(this, "trackEventWithCategory", category.c_str(),
                 action.c_str(), label.c_str(), value);
}

void GoogleProtocolAnalytics::trackException(const std::string& description,
                                             bool isFatal) {
    callFunction(this, "trackExceptionWithDescription", description.c_str(),
                 isFatal);
}

void GoogleProtocolAnalytics::trackTiming(const std::string& category,
                                          int interval, const std::string& name,
                                          const std::string& label) {
    callFunction(this, "trackTimingWithCategory", category.c_str(), interval,
                 name.c_str(), label.c_str());
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
    callFunction(this, "trackSocialWithNetwork", network.c_str(),
                 action.c_str(), target.c_str());
}

void GoogleProtocolAnalytics::setDryRun(bool isDryRun) {
    callFunction(this, "setDryRun", isDryRun);
}

void GoogleProtocolAnalytics::enableAdvertisingTracking(bool enable) {
    callFunction(this, "enableAdvertisingTracking", enable);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark
