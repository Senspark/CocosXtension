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
- (BOOL) hasMoreApps: (NSDictionary*) info;
- (void) showMoreApps: (NSDictionary*) info;
- (void) cacheMoreApps: (NSDictionary*) info;

#pragma mark - Interstitials
- (BOOL) hasInterstitial: (NSDictionary*) info;
- (void) showInterstitial: (NSDictionary*) info;
- (void) cacheInterstitial: (NSDictionary*) info;

#pragma mark - Rewarded Videos
- (BOOL) hasRewardedVideo: (NSDictionary*) info;
- (void) showRewardedVideo: (NSDictionary*) info;
- (void) cacheRewardedVideo: (NSDictionary*) info;

@end
