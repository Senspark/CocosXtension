//
//  GoogleProtocolAnalytics.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/20/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "GoogleProtocolAnalytics.h"
#include "PluginUtils.h"

namespace senspark {
namespace plugin {
namespace analytics {
GoogleProtocolAnalytics::~GoogleProtocolAnalytics() {
    PluginUtils::erasePluginJavaData(this);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark