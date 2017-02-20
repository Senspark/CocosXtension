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

class HitBuilder {
public:
    using Dict = std::map<std::string, std::string>;

    explicit HitBuilder(const std::string& type) {
        assert(type == parameters::types::screen_view ||
               type == parameters::types::event ||
               type == parameters::types::timing);
        setParameter(parameters::hit_type, type);
    }

    HitBuilder& setParameter(const std::string& key, const std::string& value) {
        dict_[key] = value;
        return *this;
    }

    Dict build() const {
        Dict result;
        for (auto&& elt : dict_) {
            result["&" + elt.first] = elt.second;
        }
        return result;
    }

private:
    Dict dict_;
};
} // namespace

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
    setParameter(parameters::screen_name, screenName);
    auto builder = HitBuilder(parameters::types::screen_view);
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackEvent(const std::string& category,
                                         const std::string& action,
                                         const std::string& label, int value) {
    auto builder =
        HitBuilder(parameters::types::event)
            .setParameter(parameters::event_category, category)
            .setParameter(parameters::event_action, action)
            .setParameter(parameters::event_label, label)
            .setParameter(parameters::event_value, std::to_string(value));
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackException(const std::string& description,
                                             bool isFatal) {
    auto builder =
        HitBuilder(parameters::types::exception)
            .setParameter(parameters::exception_description, description)
            .setParameter(parameters::is_exception_fatal, isFatal ? "1" : "0");
    sendHit(builder.build());
}

void GoogleProtocolAnalytics::trackTiming(const std::string& category,
                                          int interval, const std::string& name,
                                          const std::string& label) {
    auto builder =
        HitBuilder(parameters::types::timing)
            .setParameter(parameters::timing_category, category)
            .setParameter(parameters::timing_time, std::to_string(interval))
            .setParameter(parameters::timing_variable_name, name)
            .setParameter(parameters::timing_label, label);
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
    auto builder = HitBuilder(parameters::types::social)
                       .setParameter(parameters::social_network, network)
                       .setParameter(parameters::social_action, action)
                       .setParameter(parameters::social_action_target, target);
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
    callFunction(this, "setParameter", ("&" + key).c_str(), value.c_str());
}

void GoogleProtocolAnalytics::sendHit(
    const std::map<std::string, std::string>& parameters) {
    callFunction(this, "sendHit", parameters);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark
