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

@synthesize strInterstitialAdID = _strInterstitialAdID;
@synthesize strRewardedAdID     = _strRewardedAdID;

- (void) configDeveloperInfo:(NSDictionary *)devInfo {
    NSString* appID           = [devInfo objectForKey:@"AdColonyAppID"];
    self.strInterstitialAdID  = [devInfo objectForKey:@"AdColonyInterstitialAdZoneID"];
    self.strRewardedAdID      = [devInfo objectForKey:@"AdColonyRewardedAdZoneID"];

    // Initialize the AdColony library
    [AdColony configureWithAppID: appID
                         zoneIDs: @[self.strInterstitialAdID, self.strRewardedAdID]
                        delegate:self
                         logging:YES];

    [GADMAdapterAdColonyInitializer startWithAppID: appID
                                          andZones: @[self.strInterstitialAdID, self.strRewardedAdID]];
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

- (BOOL) hasInterstitial {
    return [AdColony zoneStatusForZone:self.strInterstitialAdID];
}

- (void) showInterstitial {
    [AdColony playVideoAdForZone:self.strInterstitialAdID withDelegate:self];
}

- (void) cacheInterstitial {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (BOOL) hasRewardedVideo {
    return [AdColony zoneStatusForZone:self.strRewardedAdID];
}

- (void) showRewardedVideo {
    [AdColony playVideoAdForZone: self.strRewardedAdID withDelegate:self withV4VCPrePopup:NO andV4VCPostPopup:NO];
}

- (void) cacheRewardedVideo {
    NSLog(@"AdColony: Not support %s", __func__);
}

- (NSString*) getSDKVersion {
    return [NSString stringWithFormat:@"%d", [AdColony version]];
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
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kAdsShown withMsg: msg];
    } else {
        [AdsWrapper onAdsResult:self withRet: AdsResultCode::kUnknownError withMsg: msg];
    }
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