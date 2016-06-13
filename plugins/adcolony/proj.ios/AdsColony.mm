//
//  AdsColony.mm
//  PluginAdColony
//
//  Created by Nikel Arteta on 1/4/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import "AdsColony.h"
#import <AdColony/AdColony.h>
#import "GADMAdapterAdColonyInitializer.h"
#import "ProtocolAds.h"
#import "AdsWrapper.h"

using namespace cocos2d::plugin;

@interface AdsColony() <AdColonyAdDelegate, AdColonyDelegate>

- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID;
- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID;
- ( void ) onAdColonyAdFinishedWithInfo:( AdColonyAdInfo * )info;
- ( void ) onAdColonyAdAvailabilityChange:( BOOL )available inZone:( NSString * )zoneID;
- ( void ) onAdColonyV4VCReward:( BOOL )success currencyName:( NSString * )currencyName currencyAmount:( int )amount inZone:( NSString * )zoneID;

@end

@implementation AdsColony

@synthesize strAdZoneID = _strAdZoneID;

- (void) configDeveloperInfo:(NSDictionary *)devInfo {
    NSString* appID  = [devInfo objectForKey:@"AdColonyAppID"];
    self.strAdZoneID = [devInfo objectForKey:@"AdColonyZoneIDs"];

    NSArray* zoneList = [self.strAdZoneID componentsSeparatedByString:@","];

    // Initialize the AdColony library
    [AdColony configureWithAppID: appID
                         zoneIDs: zoneList
                        delegate: self
                         logging: YES];
}

- (void) showAds: (NSDictionary*) info position:(int) pos {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (void) hideAds:(NSDictionary *)info {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (void) queryPoints {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (void) spendPoints:(int)points {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (void) setDebugMode:(BOOL)debug {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (BOOL) hasInterstitial:(NSString *)zoneID {
    NSLog(@"AdColony: zoneStatus: %u for Zone: %@", [AdColony zoneStatusForZone: zoneID], zoneID);
    return [AdColony zoneStatusForZone: zoneID] == ADCOLONY_ZONE_STATUS_ACTIVE ? YES : NO;
}

- (void) showInterstitial:(NSString *)zoneID {
    [AdColony playVideoAdForZone: zoneID withDelegate:self];
}

- (void) cacheInterstitial: (NSString*) zoneID {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (BOOL) hasRewardedVideo:(NSString *)zoneID {
    NSLog(@"AdColony: zoneStatus: %u for Zone: %@", [AdColony zoneStatusForZone: zoneID], zoneID);
    return [AdColony zoneStatusForZone:zoneID] == ADCOLONY_ZONE_STATUS_ACTIVE ? YES : NO;
}

- (void) showRewardedVideo:(NSDictionary *)info {
    NSString* zoneID = info[@"Param1"];
    bool isShowPrePopup = [info[@"Param2"] boolValue];
    bool isShowPostPopup = [info[@"Param3"] boolValue];

    [AdColony playVideoAdForZone: zoneID withDelegate:self withV4VCPrePopup: isShowPrePopup andV4VCPostPopup: isShowPostPopup];
}

- (void) cacheRewardedVideo: (NSString*) zoneID {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (NSString*) getSDKVersion {
    return [NSString stringWithFormat:@"%ld", (long)[AdColony version]];
}

- (NSString*) getPluginVersion {
    return @"";
}

#pragma mark - AdColony Delegate
// Is called when AdColony has taken control of the device screen and is about to begin showing an ad
// Apps should implement app-specific code such as pausing a game and turning off app music
- (void) onAdColonyAdStartedInZone:(NSString *)zoneID {
    NSString* msg = [NSString stringWithFormat:@"AdColony: Ad started in zone: %@", zoneID];
    [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoShown withMsg: msg];
}

- (void) onAdColonyAdAvailabilityChange:(BOOL)available inZone:(NSString *)zoneID {
    NSString* msg = [NSString stringWithFormat:@"AdColony: Ad availability in zone %@ change", zoneID];
    [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoReceived withMsg: msg];
}

#pragma marl - Delegate for Interstitial ad
// Is called when AdColony has finished trying to show an ad, either successfully or unsuccessfully
// If shown == YES, an ad was displayed and apps should implement app-specific code such as unpausing a game and restarting app music
- (void) onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID {
    NSString* msg = [NSString stringWithFormat:@"AdColony: Ad attemp finished in zone %@", zoneID];
    if (shown) {
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoCompleted withMsg: msg];
    } else {
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoUnknownError withMsg: msg];
    }
}

- ( void ) onAdColonyAdFinishedWithInfo:( AdColonyAdInfo * )info {
    
}

#pragma mark - Delegate for Rewarded ad
// Callback activated when a V4VC currency reward succeeds or fails
- (void) onAdColonyV4VCReward:(BOOL)success currencyName:(NSString *)currencyName currencyAmount:(int)amount inZone:(NSString *)zoneID {
    NSString* msg = [NSString stringWithFormat:@"AdColony: Ad V4VC reward in zone %@", zoneID];
    if (success) {
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoCompleted withMsg: msg];
    } else {
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kVideoDismissed withMsg: msg];
    }
}

@end