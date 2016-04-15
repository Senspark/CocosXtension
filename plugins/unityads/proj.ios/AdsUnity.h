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
- (BOOL) hasInterstitial: (NSString*) zone;
- (BOOL) hasRewardedVideo: (NSString*) zone;
- (void) showInterstitial: (NSString*) zone;
- (void) showRewardedVideo: (NSString*) zone;
- (void) cacheInterstitial;

@end