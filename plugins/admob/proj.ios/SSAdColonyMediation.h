//
//  SSAdColonyMediation.h
//  PluginAdmob
//
//  Created by Zinge on 8/12/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GADAdNetworkExtras;

@interface SSAdColonyMediation : NSObject

/// Checks whether AdColony mediation is linked.
+ (BOOL)isLinkedWithAdColony;

/// Initializes the AdColony mediation with the given application id, zone ids
/// and custom id.
+ (void)startWithAppId:(NSString* _Nonnull)appId
              andZones:(NSArray* _Nonnull)zones
           andCustomId:(NSString* _Nullable)customId;

/// Creates an AdColony extras with the given zone id.
+ (id<GADAdNetworkExtras> _Nullable)extrasWithZoneId:(NSString* _Nonnull)zoneId;

@end