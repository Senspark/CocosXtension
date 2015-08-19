//
//  ProtocolBaaS.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/13/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#import "ProtocolBaaS.h"
#import "InterfaceBaaS.h"
#import "PluginProtocol.h"
#import "ParseUtils.h"

#include "PluginUtilsIOS.h"

using namespace cocos2d::plugin;

ProtocolBaaS::ProtocolBaaS() : _listener(nullptr) {
    
}

ProtocolBaaS::~ProtocolBaaS() {
    
}

void ProtocolBaaS::configDeveloperInfo(TBaaSDeveloperInfo devInfo) {
    if (devInfo.empty()) {
        PluginUtilsIOS::outputLog("The developer info is emty for %s!", this->getPluginName());
        return;
    } else {
        PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
        assert(pData != nullptr);
        
        id ocObj = pData->obj;
        if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
            NSObject<InterfaceBaaS>* curObj = ocObj;
            NSDictionary* pDict = PluginUtilsIOS::createDictFromMap(&devInfo);
            [curObj configDeveloperInfo:pDict];
        }
    }
}

void ProtocolBaaS::signUp(std::map<std::string, std::string> userInfo) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSMutableDictionary* pDict = [[NSMutableDictionary alloc] init];
        for (auto element : userInfo) {
            [pDict setObject:[NSString stringWithUTF8String:element.second.c_str()] forKey:[NSString stringWithUTF8String:element.first.c_str()]];
        }
        [curObj signUpWithParams:pDict];
    }
}

void ProtocolBaaS::signUp(std::map<std::string, std::string> userInfo, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    signUp(userInfo);
}

void ProtocolBaaS::login(const std::string& username, const std::string& password) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        [curObj loginWithUsername:[NSString stringWithUTF8String:username.c_str()] andPassword:[NSString stringWithUTF8String:password.c_str()]];
    }
}

void ProtocolBaaS::login(const std::string& username, const std::string& password,ProtocolBaaSCallback& cb) {
    setCallback(cb);
    login(username, password);
}

void ProtocolBaaS::logout() {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        [curObj logout];
    }
}

void ProtocolBaaS::logout(ProtocolBaaSCallback& cb) {
    setCallback(cb);
    logout();
}

bool ProtocolBaaS::isLoggedIn() {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        return [curObj isLoggedIn];
    }
    
    return false;
}

void ProtocolBaaS::saveObjectInBackground(const std::string& className, const std::string& json) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:json.c_str()]];
        [curObj saveObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withParams:params];
    }
}

void ProtocolBaaS::saveObjectInBackground(const std::string& className, const std::string& json, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    saveObjectInBackground(className, json);
}

const char* ProtocolBaaS::saveObject(const std::string& className, const std::string& json) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:json.c_str()]];
        return [[curObj saveObject:[NSString stringWithUTF8String:className.c_str()] withParams:params] UTF8String];
    }
    
    return nullptr;
}

void ProtocolBaaS::getObjectInBackground(const std::string& className, const std::string& objId) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        [curObj getObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()]];
    }
}

void ProtocolBaaS::getObjectInBackground(const std::string& className, const std::string& objId, ProtocolBaaSCallback& cb) {
    
    setCallback(cb);
    getObjectInBackground(className, objId);
}

const char* ProtocolBaaS::getObject(const std::string& className, const std::string& objId) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSDictionary* obj = [curObj getObject:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()]];
        
        if (obj) {
            return [[ParseUtils NSDictionaryToNSString:obj] UTF8String];
        }
    }
    
    return nullptr;
}

void ProtocolBaaS::updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:jsonChanges.c_str()]];
        
        [curObj updateObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()] withParams:params];
    }
    
}

void ProtocolBaaS::updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges, ProtocolBaaSCallback& cb) {
    setCallback(cb);
    updateObjectInBackground(className, objId, jsonChanges);
}

const char* ProtocolBaaS::updateObject(const std::string& className, const std::string& objId, const std::string& jsonChanges) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:jsonChanges.c_str()]];
        
        return [[curObj updateObject:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()] withParams:params] UTF8String];
    }
    
    return nullptr;
}