//
//  FacebookProtocolUser.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookProtocolUser.h"
#include "PluginUtilsIOS.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

USING_NS_SENSPARK_PLUGIN_USER;

using namespace cocos2d::plugin;

FacebookProtocolUser::FacebookProtocolUser() {
    
}

FacebookProtocolUser::~FacebookProtocolUser() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void FacebookProtocolUser::configureUser() {
    TUserInfo info;
    configDeveloperInfo(info);
}

void FacebookProtocolUser::loginWithReadPermissions(const std::string &permission) {
    PluginParam permissionParam(permission.c_str());
    callFuncWithParam("loginWithReadPermissions", &permissionParam, nullptr);
}

void FacebookProtocolUser::loginWithReadPermissions(const std::string &permission, FacebookProtocolUser::UserCallback &cb) {
    
    loginWithReadPermissions(permission);
}

void FacebookProtocolUser::loginWithPublishPermissions(const std::string& permissions) {
    PluginParam permissionParam(permissions.c_str());
    callFuncWithParam("loginWithPublishPermissions", &permissionParam, nullptr);
}

void FacebookProtocolUser::loginWithPublishPermissions(const std::string& permissions, FacebookProtocolUser::UserCallback& cb) {
    
    loginWithPublishPermissions(permissions);
}


std::string FacebookProtocolUser::getUserID() {
    return callStringFuncWithParam("getUserID", nullptr);
}

std::string FacebookProtocolUser::getUserFullName() {
    return callStringFuncWithParam("getUserFullName", nullptr);
}

std::string FacebookProtocolUser::getUserLastName() {
    return callStringFuncWithParam("getUserLastName", nullptr);
}

std::string FacebookProtocolUser::getUserFirstName() {
    return callStringFuncWithParam("getUserFirstName", nullptr);
}

std::string FacebookProtocolUser::getUserAvatarUrl() {
    return callStringFuncWithParam("getUserAvatarUrl", nullptr);
}

void FacebookProtocolUser::graphRequest(const std::string& graphPath, const FBParam& params, FacebookProtocolUser::UserCallback& callback) {
    
    PluginParam pathParam(graphPath.c_str());
    PluginParam paramsParam(params);
    CallbackWrapper *wrapper = new CallbackWrapper(callback);
    PluginParam cbID((long)wrapper);
    
    callFuncWithParam("graphRequestWithParams", &pathParam, &paramsParam, &cbID, nullptr);
}

void FacebookProtocolUser::api(const std::string &graphPath, HttpMethod method, const FBParam &params, FacebookProtocolUser::UserCallback &callback) {
    
    PluginParam pathParam(graphPath.c_str());
    PluginParam _method((int) method);
    PluginParam paramsParam(params);
    CallbackWrapper *wrapper = new CallbackWrapper(callback);
    PluginParam cbID((long)wrapper);
    
    callFuncWithParam("api", &pathParam, &_method, &paramsParam, &cbID, NULL);
}
