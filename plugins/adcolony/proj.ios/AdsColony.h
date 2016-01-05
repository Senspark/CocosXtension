//
//  AdsColony.h
//  PluginAdColony
//
//  Created by Nikel Arteta on 1/4/16.
//  Copyright © 2016 Senspark Co., Ltd. All rights reserved.
//

#ifndef AdsColony_h
#define AdsColony_h

#import <Foundation/Foundation.h>
#import "InterfaceAds.h"

@interface AdsColony : NSObject <InterfaceAds>

@property (copy, nonatomic) NSString* strInterstitialAdID;
@property (copy, nonatomic) NSString* strRewardedAdID;

#pragma mark - Interstitials
- (BOOL) hasInterstitial;
- (void) showInterstitial;
- (void) cacheInterstitial;

#pragma mark - Rewarded Videos
- (BOOL) hasRewardedVideo;
- (void) showRewardedVideo;
- (void) cacheRewardedVideo;

@end


#endif /* AdsColony_h */
