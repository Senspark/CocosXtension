//
//  ProtocolPlatform.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 1/5/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EReachability.h"

#include "ProtocolPlatform.h"

static EReachability* _reachability = nullptr;

USING_NS_CC_PLUGIN;

ProtocolPlatform::ProtocolPlatform() {
    _reachability = [[EReachability reachabilityWithHostName:@"www.google.com"] retain];
    _reachability.reachableBlock = ^void(EReachability * reachability) {
        if (_callback) {
            _callback(PlatformResultCode::kConnected, "");
        }
    };
    
    _reachability.unreachableBlock = ^void(EReachability * reachability) {
        if (_callback) {
            _callback(PlatformResultCode::kUnconnected, "");
        }
    };
    
    [_reachability startNotifier];
}

ProtocolPlatform::~ProtocolPlatform() {
    [_reachability release];
}

bool ProtocolPlatform::isAppInstalled(const std::string& url) {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithUTF8String:url.c_str()]]];
}

bool ProtocolPlatform::isConnected(const std::string& hostName) {
    EReachability *reachability = [EReachability reachabilityWithHostName:[NSString stringWithUTF8String:hostName.c_str()]];
    
    return [reachability isReachable];
}

double ProtocolPlatform::getVersionCode() {
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    return [versionString doubleValue];
}
