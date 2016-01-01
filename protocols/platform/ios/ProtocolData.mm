//
//  ProtocolData.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "InterfaceData.h"
#import "PluginProtocol.h"

#include "ProtocolData.h"
#include "PluginUtilsIOS.h"


namespace cocos2d { namespace plugin {
    
    ProtocolData::ProtocolData()
    : _listener(NULL)
    {
    }
    
    ProtocolData::~ProtocolData()
    {
    }
    
    void ProtocolData::configDeveloperInfo(TDataDeveloperInfo devInfo)
    {
        PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
        assert(pData != NULL);
        
        id ocObj = pData->obj;
        if ([ocObj conformsToProtocol:@protocol(InterfaceData)]) {
            NSObject<InterfaceData>* curObj = ocObj;
            NSMutableDictionary* pDict = PluginUtilsIOS::createDictFromMap(&devInfo);
            [curObj configDeveloperInfo:pDict];
        }
    }
    
    void ProtocolData::openData(const std::string &fileName, cocos2d::plugin::DataConflictPolicy policy) {
        PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
        assert(pData != nil);
        
        id ocObj = pData->obj;
        if ([ocObj conformsToProtocol:@protocol(InterfaceData)]) {
            NSObject<InterfaceData>* curObj = ocObj;
            [curObj openDataWithFileName:[NSString stringWithUTF8String:fileName.c_str()] andConflictPolicy:policy];
        }
    }
    
    void ProtocolData::readCurrentData() {
        PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
        assert(pData != nil);
        
        id ocObj = pData->obj;
        if ([ocObj conformsToProtocol:@protocol(InterfaceData)]) {
            NSObject<InterfaceData>* curObj = ocObj;
            [curObj readCurrentData];
        }
    }
    
    void ProtocolData::resolveConflict(const std::string& conflictId, void* data, long length, std::map<std::string, std::string>& changes) {
        PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
        assert(pData != nil);
        
        id ocObj = pData->obj;
        if ([ocObj conformsToProtocol:@protocol(InterfaceData)]) {
            NSObject<InterfaceData>* curObj = ocObj;
            NSMutableDictionary* pDict = PluginUtilsIOS::createDictFromMap(&changes);
            NSString *conflictIdStr = [NSString stringWithUTF8String:conflictId.c_str()];
            NSData *nsData = [[NSData alloc] initWithBytesNoCopy:data length:length freeWhenDone:YES];
            
            [curObj resolveConflict:conflictIdStr withData:nsData andInfo:pDict];
        }
    }
    
    void ProtocolData::commitData(void *data, long length, const char *imagePath, const std::string &description) {
            PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
            assert(pData != nil);
            
            id ocObj = pData->obj;
            if ([ocObj conformsToProtocol:@protocol(InterfaceData)]) {
                NSObject<InterfaceData>* curObj = ocObj;
                NSData *nsData = [[NSData alloc] initWithBytesNoCopy:data length:length freeWhenDone:YES];
                
                [curObj commitCurrentData:nsData withImage: imagePath ? [NSString stringWithUTF8String:imagePath] : nil andDescription: [NSString stringWithUTF8String:description.c_str()]];
            }
    }
}} // namespace cocos2d { namespace plugin {