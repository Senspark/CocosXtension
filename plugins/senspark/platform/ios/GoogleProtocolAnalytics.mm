//
//  GoogleProtocolAnalytics.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/20/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GoogleProtocolAnalytics.h"
#include "PluginUtilsIOS.h"

namespace senspark {
namespace plugin {
namespace analytics {
GoogleProtocolAnalytics::~GoogleProtocolAnalytics() {
    cocos2d::plugin::PluginUtilsIOS::erasePluginOCData(this);
}
} // namespace analytics
} // namespace plugin
} // namespace senspark