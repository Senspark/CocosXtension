//
//  FacebookProtocolShare.m
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "FacebookProtocolShare.h"
#include "PluginUtilsIOS.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

USING_NS_SENSPARK_PLUGIN_SHARE;
using namespace cocos2d::plugin;

FacebookProtocolShare::FacebookProtocolShare() {
    
}

FacebookProtocolShare::~FacebookProtocolShare() {
    PluginUtilsIOS::erasePluginOCData(this);
}


void FacebookProtocolShare::share(FBParam &info, FacebookProtocolShare::ShareCallback& callback) {
    ProtocolShare::share(info, callback);
}

void FacebookProtocolShare::likeFanpage(const std::string &fanpageID) {
    PluginParam param(fanpageID.c_str());
    
    callFuncWithParam("likeFanpage", &param, nullptr);
}

void FacebookProtocolShare::openInviteDialog(FBParam &info, FacebookProtocolShare::ShareCallback& callback){
    FacebookProtocolShare::CallbackWrapper* wrapper = new FacebookProtocolShare::CallbackWrapper(callback);
    
    PluginParam params(info);
    PluginParam callbackID((long)wrapper);
    
    callFuncWithParam("openInviteDialog", &params, &callbackID, nullptr);
}

void FacebookProtocolShare::sendGameRequest(FBParam &info, FacebookProtocolShare::ShareCallback& callback) {
    FacebookProtocolShare::CallbackWrapper* wrapper = new FacebookProtocolShare::CallbackWrapper(callback);
    
    PluginParam params(info);
    PluginParam callbackID((long)wrapper);
    
    callFuncWithParam("sendGameRequest", &params, &callbackID, nullptr);
}

