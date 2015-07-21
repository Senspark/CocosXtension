//
//  SensparkProtocolAnalytics.cpp
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/20/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "InterfaceAnalytics.h"
#include "SensparkProtocolAnalytics.h"
#include "PluginUtilsIOS.h"

USING_NS_SENSPARK_PLUGIN;
using namespace cocos2d::plugin;

SensparkProtocolAnalytics::SensparkProtocolAnalytics() {
    
}

SensparkProtocolAnalytics::~SensparkProtocolAnalytics() {
    PluginUtilsIOS::erasePluginOCData(this);
}

void SensparkProtocolAnalytics::configureTracker(const string& trackerId) {
    PluginParam trackerIdParam(trackerId.c_str());
    callFuncWithParam("configureTracker", &trackerIdParam, nullptr);
}

void SensparkProtocolAnalytics::createTracker(const string& trackerId) {
    PluginParam trackerIdParam(trackerId.c_str());
    callFuncWithParam("createTracker", &trackerIdParam, nullptr);
}

void SensparkProtocolAnalytics::enableTracker(const string& trackerId) {
    PluginParam trackerIdParam(trackerId.c_str());
    callFuncWithParam("enableTracker", &trackerIdParam, nullptr);
}

void SensparkProtocolAnalytics::startSession(const char* appName) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceAnalytics)]) {
        NSObject<InterfaceAnalytics>* curObj = ocObj;
        NSString* pStrKey = [NSString stringWithUTF8String:appName];
        [curObj startSession:pStrKey];
    }
}

void SensparkProtocolAnalytics::stopSession() {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceAnalytics)]) {
        NSObject<InterfaceAnalytics>* curObj = ocObj;
        [curObj stopSession];
    }
}

void SensparkProtocolAnalytics::setCaptureUncaughtException(bool isEnabled) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceAnalytics)]) {
        NSObject<InterfaceAnalytics>* curObj = ocObj;
        [curObj setCaptureUncaughtException:isEnabled];
    }
}

void SensparkProtocolAnalytics::dispatchHits() {
    callFuncWithParam("dispatchHits", nullptr);
}

void SensparkProtocolAnalytics::dispatchPeriodically(int seconds) {
    PluginParam secondsParam(seconds);
    callFuncWithParam("dispatchHits", &secondsParam, nullptr);
}

void SensparkProtocolAnalytics::stopPeriodicalDispatch() {
    callFuncWithParam("stopPeriodcalDispatch", nullptr);
}

void SensparkProtocolAnalytics::logScreen(const string& screenName) {
    
}

void SensparkProtocolAnalytics::logEvent(const string& category, const string& action, const string& label, float value) {
    
}

void SensparkProtocolAnalytics::logException(const string& description, bool isFatal) {
    
}

void SensparkProtocolAnalytics::logTimming(const string& category, int interval, const string& name, const string& label) {
    
}

void SensparkProtocolAnalytics::logSocial(const string& network, const string& action, const string& target) {
    
}

void SensparkProtocolAnalytics::setDryRun(bool isDryRun) {
    PluginParam dryRun(isDryRun);
    callFuncWithParam("setDryRun", &dryRun, nullptr);
}

void SensparkProtocolAnalytics::enableAdvertisingTracking(bool enable) {
    PluginParam enableParam(enable);
    callFuncWithParam("enableAdvertisingTracking", &enableParam, nullptr);
}