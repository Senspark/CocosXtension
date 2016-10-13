//
//  SSBannerAdListener.cpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSBannerAdListener.h"
#import "SSAdMobUtility.h"

@implementation SSBannerAdListener

#pragma mark Ad Request Lifecycle Notifications

- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSBannerAdLoaded message:@"Banner ad view did receive ad"];
}

- (void)adView:(GADBannerView*)view
    didFailToReceiveAdWithError:(GADRequestError*)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    [self onResult:SSBannerAdFailedToLoad message:[error localizedDescription]];
}

#pragma mark Click-Time Lifecycle Notifications

- (void)adViewWillPresentScreen:(GADBannerView*)bannerView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSBannerAdOpened
           message:@"Banner ad view will present screen"];
}

- (void)adViewWillDismissScreen:(GADBannerView*)bannerView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Ignored, Android doesn't have equivalent callback.
}

- (void)adViewDidDismissScreen:(GADBannerView*)bannerView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSBannerAdClosed
           message:@"Banner ad view did dismiss screen"];
}

- (void)adViewWillLeaveApplication:(GADBannerView*)bannerView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSBannerAdLeftApplication
           message:@"Banner ad view will leave application"];
}

@end
