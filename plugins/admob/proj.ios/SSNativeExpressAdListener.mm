//
//  NativeExpressAdListener.m
//  PluginAdmob
//
//  Created by Zinge on 6/22/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import "SSNativeExpressAdListener.h"
#import "AdsWrapper.h"
#import "InterfaceAds.h"

#include "ProtocolAds.h"

@implementation SSNativeExpressAdListener

- (id _Nullable) initWithAdsInterface:(id _Nonnull) interface {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    NSAssert([interface conformsToProtocol:@protocol(InterfaceAds)], @"...");
    
    _interface = interface;
    
    return self;
}

#pragma mark Ad Request Lifecycle Notifications

- (void) nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView*) nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [AdsWrapper onAdsResult:[self interface]
                    withRet:AdsResultCode::NativeExpressAdLoaded
                    withMsg:@"Native express ad received"];
}

- (void) nativeExpressAdView:(GADNativeExpressAdView*) nativeExpressAdView
 didFailToReceiveAdWithError:(GADRequestError*) error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    [AdsWrapper onAdsResult:[self interface]
                    withRet:AdsResultCode::NativeExpressAdFailedToLoad
                    withMsg:[error localizedDescription]];
}

#pragma mark Click-Time Lifecycle Notifications

- (void) nativeExpressAdViewWillPresentScreen:(GADNativeExpressAdView*) nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [AdsWrapper onAdsResult:[self interface]
                    withRet:AdsResultCode::NativeExpressAdOpened
                    withMsg:@"Ads view shown!"];
}

- (void) nativeExpressAdViewWillDismissScreen:(GADNativeExpressAdView*) nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void) nativeExpressAdViewDidDismissScreen:(GADNativeExpressAdView*) nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [AdsWrapper onAdsResult:[self interface]
                    withRet:AdsResultCode::NativeExpressAdClosed
                    withMsg:@"Ads view closed!"];
}

- (void) nativeExpressAdViewWillLeaveApplication:(GADNativeExpressAdView*) nativeExpressAdView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [AdsWrapper onAdsResult:[self interface]
                    withRet:AdsResultCode::NativeExpressAdLeftApplication
                    withMsg:@"Ads left application!"];
}

@end