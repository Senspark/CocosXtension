//
//  GooglePlayProtocolData.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//
#include "GooglePlusProtocolUser.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_USER;
using namespace cocos2d::plugin;

GooglePlusProtocolUser::GooglePlusProtocolUser() {

}

GooglePlusProtocolUser::~GooglePlusProtocolUser() {
    PluginUtils::erasePluginJavaData(this);
}

void GooglePlusProtocolUser::configureUser(const std::string& appId) {
    TUserInfo devInfo;
    devInfo["GoogleClientID"] = appId;
    configDeveloperInfo(devInfo);
}

std::string GooglePlusProtocolUser::getUserAvatarUrl() {
    return callStringFuncWithParam("getUserAvatarUrl", nullptr);
}

std::string GooglePlusProtocolUser::getUserDisplayName() {
    return callStringFuncWithParam("getUserDisplayName", nullptr);
}

std::string GooglePlusProtocolUser::getUserID() {
    return callStringFuncWithParam("getUserID", nullptr);
}
