//
//  SSAdColonyMediation.m
//  PluginAdmob
//
//  Created by Zinge on 8/12/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSAdColonyMediation.h"

@implementation SSAdColonyMediation

+ (BOOL)isLinkedWithAdColony {
    Class clazz = NSClassFromString(@"GADMAdapterAdColonyInitializer");
    return clazz != nil;
}

+ (void)startWithAppId:(NSString* _Nonnull)appId
              andZones:(NSArray* _Nonnull)zones
           andCustomId:(NSString* _Nullable)customId {
    if ([self isLinkedWithAdColony]) {
        Class clazz = NSClassFromString(@"GADMAdapterAdColonyInitializer");
        SEL method =
            NSSelectorFromString(@"startWithAppID:andZones:andCustomID:");

        NSMethodSignature* signature =
            [clazz methodSignatureForSelector:method];
        NSInvocation* invocation =
            [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:method];
        [invocation setTarget:clazz];
        [invocation setArgument:&appId atIndex:2];
        [invocation setArgument:&zones atIndex:3];
        if (customId != nil) {
            [invocation setArgument:&customId atIndex:4];
        }
        [invocation invoke];
    }
}

+ (id<GADAdNetworkExtras> _Nullable)extrasWithZoneId:
        (NSString* _Nonnull)zoneId {
    if ([self isLinkedWithAdColony]) {
        Class clazz = NSClassFromString(@"GADMAdapterAdColonyExtras");
        SEL method = NSSelectorFromString(@"initWithZone:");
        id extras = [clazz alloc];
        NSAssert([extras respondsToSelector:method], @"...");
        [extras performSelector:extras withObject:zoneId];
        return extras;
    }
    return nil;
}

@end
