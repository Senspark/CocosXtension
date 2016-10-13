//
//  NativeExpressAdListener.m
//  PluginAdmob
//
//  Created by Zinge on 6/22/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSNativeExpressAdListener.h"
#import "SSAdMobUtility.h"

@implementation SSNativeExpressAdListener

#pragma mark Ad Request Lifecycle Notifications

- (void)nativeExpressAdViewDidReceiveAd:
        (GADNativeExpressAdView*)nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSNativeExpressAdLoaded
           message:@"Native express ad view did receive ad"];
}

- (void)nativeExpressAdView:(GADNativeExpressAdView*)nativeExpressAdView
    didFailToReceiveAdWithError:(GADRequestError*)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    [self onResult:SSNativeExpressAdFailedToLoad
           message:[error localizedDescription]];
}

#pragma mark Click-Time Lifecycle Notifications

- (void)nativeExpressAdViewWillPresentScreen:
        (GADNativeExpressAdView*)nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSNativeExpressAdOpended
           message:@"Native express ad view will present screen"];
}

- (void)nativeExpressAdViewWillDismissScreen:
        (GADNativeExpressAdView*)nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // Ignored, Android doesn't have equivalent callback.
}

- (void)nativeExpressAdViewDidDismissScreen:
        (GADNativeExpressAdView*)nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSNativeExpressAdClosed
           message:@"Native express ad view did dismiss screen"];
}

- (void)nativeExpressAdViewWillLeaveApplication:
        (GADNativeExpressAdView*)nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSNativeExpressAdLeftApplication
           message:@"Native express ad view will leave application"];
}

@end
