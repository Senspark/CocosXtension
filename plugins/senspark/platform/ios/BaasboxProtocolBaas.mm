//
//  BaasboxProtocolBaas.m
//  PluginSenspark
//
//  Created by Tran Van Tuan on 12/22/15.
//  Copyright © 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaasboxProtocolBaas.h"
#import "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;
using namespace std;

BaasboxProtocolBaaS::~BaasboxProtocolBaaS(){
    PluginUtilsIOS::erasePluginOCData(this);
}

void BaasboxProtocolBaaS::loginWithFacebookToken(const std::string &facebookToken, BaaSCallback &cb){
    PluginParam fbTokenparams(facebookToken.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("loginWithFacebookToken", &fbTokenparams, &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::updateProfileUser(const std::string &jsonData, BaaSCallback &cb){
    PluginParam jsonDataparams(jsonData.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("loginWithFacebookToken", &jsonDataparams, &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::fetchProfileUser(BaaSCallback &cb){
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long) wrapper);
    
    callFuncWithParam("fetchProfileUserWithCallbackId", &callbackParam, nullptr);
}