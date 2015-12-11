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

void ProtocolBaaS::configDeveloperInfo(TBaaSInfo devInfo) {
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

#pragma mark - Sign up
void ProtocolBaaS::signUp(std::map<std::string, std::string> userInfo, BaaSCallback& cb) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSMutableDictionary* pDict = [[NSMutableDictionary alloc] init];
        for (auto element : userInfo) {
            [pDict setObject:[NSString stringWithUTF8String:element.second.c_str()] forKey:[NSString stringWithUTF8String:element.first.c_str()]];
        }
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        [curObj signUpWithParams:pDict andCallbackID:(long) cbWrapper];
    }
}

#pragma mark - Login
void ProtocolBaaS::login(const std::string& username, const std::string& password, BaaSCallback& cb) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        
        [curObj loginWithUsername:[NSString stringWithUTF8String:username.c_str()] andPassword:[NSString stringWithUTF8String:password.c_str()] andCallbackID:(long) cbWrapper];
    }
}

#pragma mark - Logout

void ProtocolBaaS::logout(BaaSCallback& cb) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        [curObj logout:(long)cbWrapper];
    }
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

string ProtocolBaaS::getUserID() {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        const char* userID = [[curObj getUserID] UTF8String];
        return userID ? userID : "";
    }
    
    return "";
}


#pragma mark - Save object
void ProtocolBaaS::saveObjectInBackground(const std::string& className, const std::string& json, BaaSCallback& cb) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:json.c_str()]];
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        
        [curObj saveObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withParams:params andCallbackID:(long)cbWrapper];
    }
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

#pragma mark - Get object
void ProtocolBaaS::getObjectInBackground(const std::string& className, const std::string& objId, BaaSCallback& cb) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        
        [curObj getObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()] andCallbackID:(long)cbWrapper];
    }
}

void ProtocolBaaS::getObjectsInBackground(const std::string& className, const std::vector<std::string>& objIds, BaaSCallback& cb) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (auto objId : objIds) {
            [array addObject:[NSString stringWithUTF8String:objId.c_str()]];
        }
        
        CallbackWrapper* cbWrapper = new CallbackWrapper(cb);
        
        [curObj getObjectsInBackground:[NSString stringWithUTF8String:className.c_str()] withIds: array andCallbackID:(long) cbWrapper];
    }
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

void ProtocolBaaS::findObjectsInBackground(const std::string& className, const std::string& key, const std::vector<std::string>& values, BaaSCallback& cb) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        for (auto value : values) {
            [array addObject:[NSString stringWithUTF8String:value.c_str()]];
        }
        
        CallbackWrapper *callback = new CallbackWrapper(cb);
        
        [curObj findObjectsInBackground:[NSString stringWithUTF8String:className.c_str()] whereKey:[NSString stringWithUTF8String:key.c_str()] containedIn:array withCallbackID:(long)callback];
    }
}

#pragma mark - Update object
void ProtocolBaaS::updateObjectInBackground(const std::string& className, const std::string& objId, const std::string& jsonChanges, BaaSCallback& cb) {
    
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;
        
        NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:[NSString stringWithUTF8String:jsonChanges.c_str()]];
        
        CallbackWrapper *callback = new CallbackWrapper(cb);
        
        [curObj updateObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()] withParams:params andCallbackID:(long)callback];
    }
    
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

#pragma mark - Delete object
void ProtocolBaaS::deleteObjectInBackground(const std::string& className, const std::string& objId, BaaSCallback& cb) {

    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);

    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;

        CallbackWrapper *callback = new CallbackWrapper(cb);
        
        [curObj deleteObjectInBackground:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()] andCallbackID:(long)callback];
    }

}

bool ProtocolBaaS::deleteObject(const std::string& className, const std::string& objId) {

    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != nullptr);

    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
        NSObject<InterfaceBaaS>* curObj = ocObj;

        return [curObj deleteObject:[NSString stringWithUTF8String:className.c_str()] withId:[NSString stringWithUTF8String:objId.c_str()]];
    }

    return false;
}

#pragma mark - Get Parse Config
void ProtocolBaaS::fetchConfigInBackground(BaaSCallback& cb) {
//    setCallback(cb);
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//    
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        [curObj fetchConfigInBackground];
//    }
}

bool ProtocolBaaS::getBoolConfig(const std::string &param) {
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        return [curObj getBoolConfig:[NSString stringWithUTF8String:param.c_str()]];
//    }
    return false;
}

int ProtocolBaaS::getIntegerConfig(const std::string &param) {
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        return [curObj getIntegerConfig:[NSString stringWithUTF8String:param.c_str()]];
//    }
    return 0;
}

double ProtocolBaaS::getDoubleConfig(const std::string &param) {
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        return [curObj getDoubleConfig:[NSString stringWithUTF8String:param.c_str()]];
//    }
    return 0;
}

long ProtocolBaaS::getLongConfig(const std::string &param) {
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        return [curObj getLongConfig:[NSString stringWithUTF8String:param.c_str()]];
//    }
    return 0;
}

const char* ProtocolBaaS::getStringConfig(const std::string &param) {
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        return [[curObj getStringConfig:[NSString stringWithUTF8String:param.c_str()]] UTF8String];
//    }
    return nullptr;
}

const char* ProtocolBaaS::getArrayConfig(const std::string &param) {
//    NSString* nsParam = [NSString stringWithUTF8String:param.c_str()];
//    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
//    assert(pData != nullptr);
//
//    id ocObj = pData->obj;
//    if ([ocObj conformsToProtocol:@protocol(InterfaceBaaS)]) {
//        NSObject<InterfaceBaaS>* curObj = ocObj;
//        NSDictionary* nsDict = [curObj getArrayConfig:nsParam];
//        const char* ret = [[ParseUtils NSDictionaryToNSString:nsDict] UTF8String];
//        return ret;
//    }
    return nullptr;
}