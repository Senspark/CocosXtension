//
//  ParseProtocolBaaS.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 8/17/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParseProtocolBaaS.h"
#import "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;
using namespace std;

ParseProtocolBaaS::~ParseProtocolBaaS() {
    PluginUtilsIOS::erasePluginOCData(this);
};

std::string ParseProtocolBaaS::getUserInfo() {
    return callStringFuncWithParam("getUserInfo", nullptr);
}

std::string ParseProtocolBaaS::setUserInfo(const map<string, string> &changes) {
    PluginParam params(changes);
    
    return callStringFuncWithParam("setUserInfo", &params, nullptr);
}

void ParseProtocolBaaS::saveUserInfo(BaaSCallback &cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("saveUserInfo", &callbackParam, nullptr);
}

void ParseProtocolBaaS::fetchUserInfo(BaaSCallback &cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("fetchUserInfo", &callbackParam, nullptr);
}

std::string ParseProtocolBaaS::getInstallationInfo() {
    return callStringFuncWithParam("getInstallationInfo", nullptr);
}

std::string ParseProtocolBaaS::setInstallationInfo(const std::map<std::string, std::string>& changes) {
    PluginParam params(changes);
    
    return callStringFuncWithParam("setInstallationInfo", &params, nullptr);
}

void ParseProtocolBaaS::saveInstallationInfo(BaaSCallback& cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    PluginParam callbackParam((long) wrapper);
    callFuncWithParam("saveInstallationInfo", &callbackParam, nullptr);
}

void ParseProtocolBaaS::loginWithFacebookAccessToken(BaaSCallback& cb) {
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("loginWithFacebookAccessToken", &callbackParam, nullptr);
}


void ParseProtocolBaaS::subcribeChannel(const std::string &channel) {
    
}

void ParseProtocolBaaS::unsubcribeChannel(const std::string &channel) {
    
}
