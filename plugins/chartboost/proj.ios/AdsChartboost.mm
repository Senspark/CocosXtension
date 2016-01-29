//
//  AdsChartboost.m
//  PluginChartboost
//
//  Created by Duc Nguyen on 1/3/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import "AdsChartboost.h"
#import <UIKit/UIKit.h>
#import <Chartboost/Chartboost.h>
#import "ProtocolAds.h"
#include "AdsWrapper.h"

using namespace cocos2d::plugin;

@interface AdsChartboost() <ChartboostDelegate>

- (void)didDisplayInterstitial:(CBLocation)location;
- (void)didCacheInterstitial:(CBLocation)location;
- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error;
- (void)didDismissInterstitial:(CBLocation)location;
- (void)didCloseInterstitial:(CBLocation)location;
- (void)didClickInterstitial:(CBLocation)location;

- (void)didDisplayMoreApps:(CBLocation)location;
- (void)didCacheMoreApps:(CBLocation)location;
- (void)didDismissMoreApps:(CBLocation)location;
- (void)didFailToLoadMoreApps:(CBLocation)location
                    withError:(CBLoadError)error;
- (void)didCloseMoreApps:(CBLocation)location;
- (void)didClickMoreApps:(CBLocation)location;

- (void)didDisplayRewardedVideo:(CBLocation)location;
- (void)didCacheRewardedVideo:(CBLocation)location;
- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error;
- (void)didDismissRewardedVideo:(CBLocation)location;
- (void)didCloseRewardedVideo:(CBLocation)location;
- (void)didClickRewardedVideo:(CBLocation)location;
- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward;
@end

@implementation AdsChartboost

- (void) configDeveloperInfo: (NSDictionary*) devInfo {
    NSString* appID     = [devInfo objectForKey:@"ChartboostAppID"];
    NSString* signature = [devInfo objectForKey:@"ChartboostSignature"];
    
    [Chartboost startWithAppId:appID appSignature:signature delegate:self];
    [Chartboost setAutoCacheAds:YES];
}

- (void) showAds: (NSDictionary*) info position:(int) pos {
    NSString* location = [info objectForKey:@"location"];
    
    [Chartboost showInterstitial:location];
}

- (void) hideAds: (NSDictionary*) info {
    NSLog(@"Chartboost: Not support %s", __func__);
}

- (void) queryPoints {
    NSLog(@"Chartboost: Not support %s", __func__);
}

- (void) spendPoints: (int) points {
    NSLog(@"Chartboost: Not support %s", __func__);
}

- (void) setDebugMode: (BOOL) debug {
    NSLog(@"Chartboost: Not support %s", __func__);
}

- (CBLocation) getCBLocationFrom: (NSDictionary*) info {
    NSString* strLocation = [info objectForKey:@"location"];
    
    NSArray* cbStrLocations = @[@"CBLocationStartup",
                             @"CBLocationHomeScreen",
                             @"CBLocationMainMenu",
                             @"CBLocationGameScreen",
                             @"CBLocationAchievements",
                             @"CBLocationQuests",
                             @"CBLocationPause",
                             @"CBLocationLevelStart",
                             @"CBLocationLevelComplete",
                             @"CBLocationTurnComplete",
                             @"CBLocationIAPStore",
                             @"CBLocationItemStore",
                             @"CBLocationGameOver",
                             @"CBLocationLeaderBoard",
                             @"CBLocationSettings",
                             @"CBLocationQuit",
                             @"CBLocationDefault"];
    
    NSArray* cbLocations =      @[CBLocationStartup,
                                CBLocationHomeScreen,
                                CBLocationMainMenu,
                                CBLocationGameScreen,
                                CBLocationAchievements,
                                CBLocationQuests,
                                CBLocationPause,
                                CBLocationLevelStart,
                                CBLocationLevelComplete,
                                CBLocationTurnComplete,
                                CBLocationIAPStore,
                                CBLocationItemStore,
                                CBLocationGameOver,
                                CBLocationLeaderBoard,
                                CBLocationSettings,
                                CBLocationQuit,
                                CBLocationDefault];
    
    for (int i = 0; i < [cbStrLocations count]; i++) {
        if ([[cbStrLocations objectAtIndex:i] compare:strLocation] == NSOrderedSame) {
            return [cbLocations objectAtIndex:i];
        }
    }
    
    return CBLocationDefault;
}

- (BOOL) hasMoreApps: (NSString*) locationID {
    return [Chartboost hasMoreApps:locationID];
}

- (void) cacheMoreApps: (NSString*) locationID {
    [Chartboost cacheMoreApps:locationID];
}

- (void) showMoreApps: (NSString*) locationID {
    [Chartboost showMoreApps:locationID];
}

- (BOOL) hasInterstitial: (NSString*) locationID {
    return [Chartboost hasInterstitial:locationID];
}

- (void) showInterstitial: (NSString*) locationID {
    [Chartboost showInterstitial:locationID];
}

- (void) cacheInterstitial: (NSString*) locationID {
    [Chartboost cacheInterstitial:locationID];
}

- (BOOL) hasRewardedVideo: (NSString*) locationID {
    return [Chartboost hasRewardedVideo:locationID];
}

- (void) showRewardedVideo: (NSString*) locationID {
    [Chartboost showRewardedVideo:locationID];
}

- (void) cacheRewardedVideo: (NSString*) locationID {
    [Chartboost cacheRewardedVideo:locationID];
}

- (NSString*) getSDKVersion {
    return [NSString stringWithFormat:@"%ld", (long)[Chartboost version]];
}

- (NSString*) getPluginVersion {
    return @"";
}

#pragma mark - Chartboost Delegate
- (void)didDisplayInterstitial:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsShown withMsg:location];
}

- (void)didCacheInterstitial:(CBLocation)location {
    NSLog(@"CHARTBOOST INTERSTITIAL did cached at location: %@", location);
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsReceived withMsg:location];
}

- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kUnknownError withMsg:location];
}

- (void)didDismissInterstitial:(CBLocation)location {
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsDismissed withMsg:location];
}

- (void)didCloseInterstitial:(CBLocation)location {
    NSLog(@"Chartboost: %s", __func__);
}

- (void)didClickInterstitial:(CBLocation)location {
    NSLog(@"Chartboost: %s", __func__);
}

- (void)didDisplayMoreApps:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kMoreAppsShown withMsg:location];
}

- (void)didCacheMoreApps:(CBLocation)location {
    NSLog(@"CHARTBOOST MORE APPS did cached at location: %@", location);
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kMoreAppsReceived withMsg:location];
}

- (void)didDismissMoreApps:(CBLocation)location {
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kMoreAppsDismissed withMsg:location];
}

- (void)didFailToLoadMoreApps:(CBLocation)location
                    withError:(CBLoadError)error {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kUnknownError withMsg:location];
}

- (void)didCloseMoreApps:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kMoreAppsClosed withMsg:location];
}

- (void)didClickMoreApps:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kMoreAppsClicked withMsg:location];
}

- (void)didDisplayRewardedVideo:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoShown withMsg:location];
}

- (void)didCacheRewardedVideo:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoReceived withMsg:location];
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kUnknownError withMsg:location];
}

- (void)didDismissRewardedVideo:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoDismissed withMsg:location];
}

- (void)didCloseRewardedVideo:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoClosed withMsg:location];
}

- (void)didClickRewardedVideo:(CBLocation)location {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoClicked withMsg:location];
}
- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward {
//    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoCompleted withMsg: [NSString stringWithFormat:@"{\"location\": %@, \"reward\": %d}", location, reward] ];
}

@end
