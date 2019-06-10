//
//  BaasboxProtocolBaaS.m
//  PluginSenspark
//
//  Created by Tran Van Tuan on 12/22/15.
//  Copyright © 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaasboxProtocolBaaS.h"
#import "PluginUtilsIOS.h"
#import "ProtocolBaaS.h"
#import "PluginProtocol.h"


USING_NS_SENSPARK_PLUGIN_BAAS;
using namespace cocos2d::plugin;
using namespace std;

BaasboxProtocolBaaS::~BaasboxProtocolBaaS(){
    PluginUtilsIOS::erasePluginOCData(this);
}

void BaasboxProtocolBaaS::loginWithFacebookToken(const std::string &facebookToken, BaaSCallback &cb){
    PluginParam facebookTokenParam(facebookToken.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("loginWithFacebookToken", &facebookTokenParam, &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::updateUserProfile(const std::string &profile, BaaSCallback &cb){
    PluginParam profileParam(profile.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("updateUserProfile", &profileParam, &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::fetchUserProfile(BaaSCallback &cb){
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("fetchUserProfileWithCallbackId", &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::loadUsersWithParameters(const std::string& condition, BaaSCallback &cb){
    PluginParam conditionParam(condition.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long long) wrapper);
    
    callFuncWithParam("loadUsersWithParameters", &conditionParam, &callbackParam, nullptr);
}

void BaasboxProtocolBaaS::loadAssetJSON(const std::string &assetName, BaaSCallback &cb){
    PluginParam assetNameParam(assetName.c_str());
    
    CallbackWrapper *wrapper = new CallbackWrapper(cb);
    
    PluginParam callbackParam((long long)wrapper);
    
    callFuncWithParam("loadAssetJSON", &assetNameParam, &callbackParam,nullptr);
}






