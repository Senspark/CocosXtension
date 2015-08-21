//
//  FacebookProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#include "FacebookProtocolUser.h"
#include "PluginUtils.h"
#include "FacebookAgent.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

FacebookProtocolUser::FacebookProtocolUser() {

}

FacebookProtocolUser::~FacebookProtocolUser() {
    PluginUtils::erasePluginJavaData(this);
}

void FacebookProtocolUser::configureUser() {
    TUserDeveloperInfo info;
    configDeveloperInfo(info);
}

void FacebookProtocolUser::loginWithReadPermissions(const std::string &permission) {
    PluginParam permissionParam(permission.c_str());
    callFuncWithParam("loginWithReadPermissions", &permissionParam, nullptr);
}

void FacebookProtocolUser::loginWithReadPermissions(const std::string &permission, FacebookProtocolUser::ProtocolUserCallback &cb) {

    setCallback(cb);
    loginWithReadPermissions(permission);
}

void FacebookProtocolUser::loginWithPublishPermissions(const std::string& permissions) {
    PluginParam permissionParam(permissions.c_str());
    callFuncWithParam("loginWithPublishPermissions", &permissionParam, nullptr);
}

void FacebookProtocolUser::loginWithPublishPermissions(const std::string& permissions, FacebookProtocolUser::ProtocolUserCallback& cb) {

    setCallback(cb);
    loginWithPublishPermissions(permissions);
}


std::string FacebookProtocolUser::getUserID() {
    return callStringFuncWithParam("getUserID", nullptr);
}

void FacebookProtocolUser::graphRequest(const std::string& graphPath, const FBParam& params, FBCallback& callback) {

    FacebookAgent::getInstance()->graphRequest(graphPath, params, callback);
}

void FacebookProtocolUser::api(const std::string &graphPath, int method, const FBParam &param, FBCallback &callback) {

    FacebookAgent::getInstance()->api(graphPath, method, param, callback);
}
