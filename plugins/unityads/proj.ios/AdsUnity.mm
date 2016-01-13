//
//  AdsUnity.mm
//  AdsUnity
//
//  Created by Nikel Arteta on 1/4/16.
//  Copyright © 2016 Senspark. All rights reserved.
//

#import "AdsUnity.h"
#import <UIKit/UIKit.h>
#import <UnityAds/UnityAds.h>
#import "ProtocolAds.h"
#include "AdsWrapper.h"

using namespace cocos2d::plugin;

@interface AdsUnity() <UnityAdsDelegate>

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped;
//- (void)unityAdsWillShow;
- (void)unityAdsDidShow;
//- (void)unityAdsWillHide;
- (void)unityAdsDidHide;
//- (void)unityAdsWillLeaveApplication;
//- (void)unityAdsVideoStarted;
//- (void)unityAdsFetchCompleted;
//- (void)unityAdsFetchFailed;

@end

@implementation AdsUnity

- (void) configDeveloperInfo: (NSDictionary*) devInfo {
    NSString* appID     = [devInfo objectForKey:@"UnityAdsAppID"];

    [[UnityAds sharedInstance] startWithGameId: appID andViewController:[AdsWrapper getCurrentRootViewController]];
    [[UnityAds sharedInstance] setDelegate:self];
}

- (void) showAds:(NSDictionary *)info position:(int)pos {
    NSLog(@"Ads Unity: Not support %s", __func__);
}

- (void) hideAds: (NSDictionary*) info {
    NSLog(@"Ads Unity: Not support %s", __func__);
}

- (void) queryPoints {
    NSLog(@"Ads Unity: Not support %s", __func__);
}

- (void) spendPoints: (int) points {
    NSLog(@"Ads Unity: Not support %s", __func__);
}

- (void) setDebugMode: (BOOL) debug {
    NSLog(@"Ads Unity: Not support %s", __func__);
}

- (BOOL) hasInterstitial {
    return [[UnityAds sharedInstance] canShowAds];
}

- (void) showInterstitial {
    if ([self hasInterstitial]) {
        [[UnityAds sharedInstance] show];

    } else {
        [AdsWrapper onAdsResult:self withRet:AdsResultCode::kUnknownError withMsg:@"UnityAds: Ad cannot show"];
    }
}

- (void) cacheInterstitial {
    NSLog(@"UnityAds: Not support %s", __func__);
}

- (NSString*) getSDKVersion {
    return [NSString stringWithFormat:@"%ld", (long)[UnityAds version]];
}

- (NSString*) getPluginVersion {
    return @"";
}

#pragma mark - UnityAds Delegate

- (void)unityAdsVideoCompleted:(NSString *)rewardItemKey skipped:(BOOL)skipped {
    if (skipped) {
        [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoDismissed withMsg:@"UnityAds: Ad is dismissed/skipped"];
    } else {
        [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoCompleted withMsg:@"UnityAds: Ad completed successfully"];
    }
}

- (void)unityAdsDidShow {
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoShown withMsg:@"UnityAds: Ads did show"];
}

- (void)unityAdsDidHide {
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoClosed withMsg:@"UnityAds: Ads did hide"];
}

@end


