//
//  SSInterstitialAdListener.cpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSInterstitialAdListener.h"
#import "SSAdMobUtility.h"

@implementation SSInterstitialAdListener

#pragma mark Ad Request Lifecycle Notifications

- (void)interstitialDidReceiveAd:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSInterstitialAdLoaded
           message:@"Interstitial ad did receive ad"];
}

- (void)interstitial:(GADInterstitial*)ad
    didFailToReceiveAdWithError:(GADRequestError*)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    [self onResult:SSInterstitialAdFailedToLoad
           message:[error localizedDescription]];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSInterstitialAdOpened
           message:@"Interstitial ad will present screen"];
}

- (void)interstitialDidFailToPresentScreen:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // No equivalent callback on Android.
}

- (void)interstitialWillDismissScreen:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // No equivalent callback on Android.
}

- (void)interstitialDidDismissScreen:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSInterstitialAdClosed
           message:@"Interstitial ad did dismiss screen"];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial*)ad {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSInterstitialAdLeftApplication
           message:@"Interstitial ad will leave application"];
}

@end
