//
//  AdsChartboost.h
//  PluginChartboost
//
//  Created by Duc Nguyen on 1/3/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"

@interface AdsChartboost : NSObject <InterfaceAds>

#pragma mark - More Apps
- (BOOL) hasMoreApps: (NSString*) info;
- (void) showMoreApps: (NSString*) info;
- (void) cacheMoreApps: (NSString*) info;

#pragma mark - Interstitials
- (BOOL) hasInterstitial: (NSString*) info;
- (void) showInterstitial: (NSString*) info;
- (void) cacheInterstitial: (NSString*) info;

#pragma mark - Rewarded Videos
- (BOOL) hasRewardedVideo: (NSString*) info;
- (void) showRewardedVideo: (NSString*) info;
- (void) cacheRewardedVideo: (NSString*) info;

@end
