//
//  SSAdMobListenerProtocol.cpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSAdMobListenerProtocol.h"
#import "InterfaceAds.h"

#include "AdsWrapper.h"

@implementation SSAdMobListenerProtocol

- (id _Nullable)initWithAdsInterface:(id _Nonnull)interface {
    self = [super init];
    if (self == nil) {
        return self;
    }

    NSAssert([interface conformsToProtocol:@protocol(InterfaceAds)], @"...");

    _interface = interface;

    return self;
}

- (void)onResult:(int)code message:(NSString* _Nullable)message {
    [AdsWrapper onAdsResult:[self interface] withRet:code withMsg:message];
}

@end
