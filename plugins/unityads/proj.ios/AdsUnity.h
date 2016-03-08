//
//  AdsUnity.h
//  AdsUnity
//
//  Created by Nikel Arteta on 1/4/16.
//  Copyright © 2016 Senspark. All rights reserved.
//

#import "AdsUnity.h"
#import <Foundation/Foundation.h>
#import "InterfaceAds.h"

@interface AdsUnity : NSObject <InterfaceAds>

#pragma mark - Interstitials
- (BOOL) hasInterstitial;
- (BOOL) hasRewardedVideo;
- (void) showInterstitial;
- (void) showRewardedVideo;
- (void) cacheInterstitial;

@end