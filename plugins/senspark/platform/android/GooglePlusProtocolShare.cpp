//
//  GooglePlayProtocolData.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//
#include "GooglePlusProtocolShare.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_SHARE;
using namespace cocos2d::plugin;

GooglePlusProtocolShare::GooglePlusProtocolShare() {

}

GooglePlusProtocolShare::~GooglePlusProtocolShare() {
    PluginUtils::erasePluginJavaData(this);
}

void GooglePlusProtocolShare::share(GPParam &info, GooglePlusProtocolShare::ShareCallback &callback) {

    ProtocolShare::share(info, callback);
}
