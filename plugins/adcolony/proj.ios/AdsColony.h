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

@property (copy, nonatomic) NSString* strAdZoneID;

#pragma mark - Interstitials
- (BOOL) hasInterstitial: (NSString*) zoneID;
- (void) showInterstitial: (NSString*) zoneID;
- (void) cacheInterstitial: (NSString*) zoneID;

#pragma mark - Rewarded Videos
- (BOOL) hasRewardedVideo: (NSString*) zoneID;
- (void) showRewardedVideo: (NSString*) zoneID showPrePopup:(BOOL) isShowPrePopup showPostPopup:(BOOL) isShowPostPopup;
- (void) cacheRewardedVideo: (NSString*) zoneID;

@end


#endif /* AdsColony_h */
