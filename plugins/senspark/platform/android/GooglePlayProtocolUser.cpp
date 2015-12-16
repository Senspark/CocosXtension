//
//  GooglePlayProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/28/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "GooglePlayProtocolUser.h"
#include "PluginUtils.h"

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

GooglePlayProtocolUser::GooglePlayProtocolUser() {

}

GooglePlayProtocolUser::~GooglePlayProtocolUser() {
    PluginUtils::erasePluginJavaData(this);
}

void GooglePlayProtocolUser::configureUser(const std::string& appId) {
    TUserInfo devInfo;
    devInfo["GoogleClientID"] = appId;

    configDeveloperInfo(devInfo);
}

std::string GooglePlayProtocolUser::getUserAvatarUrl() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserAvatarUrl");
}

std::string GooglePlayProtocolUser::getUserDisplayName() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserDisplayName");
}

std::string GooglePlayProtocolUser::getUserID() {
	return PluginUtils::callJavaStringFuncWithName(this, "getUserID");
}
