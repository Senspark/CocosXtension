//
//  SSRewardedAdListener.cpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSRewardedVideoAdListener.h"
#import "SSAdMobUtility.h"

@implementation SSRewardedVideoAdListener

- (void)rewardBasedVideoAdDidReceiveAd:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSRewardedVideoAdLoaded
           message:@"Rewarded video ad did receive ad"];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd*)rewardBasedVideoAd
    didFailToLoadWithError:(NSError*)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    [self onResult:SSRewardedVideoAdFailedToLoad
           message:[error localizedDescription]];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSRewardedVideoAdOpended
           message:@"Rewarded video ad did open"];
}

- (void)rewardBasedVideoAdDidStartPlaying:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSRewardedVideoAdStarted
           message:@"Rewarded video ad did start playing"];
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSRewardedVideoAdClosed
           message:@"Rewarded video ad did close"];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd*)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward*)reward {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSString* message = [NSString
        stringWithFormat:@"Reward received with currency %@, amount %@",
                         [reward type], [reward amount]];
    [self onResult:SSRewardedVideoAdRewarded message:message];
}

- (void)rewardBasedVideoAdWillLeaveApplication:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSRewardedVideoAdLeftApplication
           message:@"Rewarded video ad will leave application"];
}

@end
