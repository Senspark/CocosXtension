//
//  GooglePlusProtocolUser.m
//  PluginSenspark
//
//  Created by Nikel Arteta on 1/7/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "GooglePlusProtocolUser.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_USER;
using namespace cocos2d::plugin;

GooglePlusProtocolUser::GooglePlusProtocolUser() {

}

GooglePlusProtocolUser::~GooglePlusProtocolUser() {
    PluginUtilsIOS::erasePluginOCData(this);
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
