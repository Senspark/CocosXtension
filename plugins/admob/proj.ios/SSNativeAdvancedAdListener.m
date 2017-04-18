//
//  SSNativeAdvancedAdListener.m
//  PluginAdmob
//
//  Created by Duc Nguyen on 4/17/17.
//  Copyright © 2017 cocos2d-x. All rights reserved.
//

#import "SSNativeAdvancedAdListener.h"
#import "SSAdMobUtility.h"
#import "AdsAdmob.h"

@implementation SSNativeAdvancedAdListener

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self onResult:SSNativeAdvancedAdReceived message:@"Native advanced ad did received ad"];
    
    [(AdsAdmob*)self.interface displayNativeAdvancedAd: nativeAppInstallAd adLoader:adLoader]; 
}

- (void)adLoader:(GADAdLoader *)adLoader
    didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    
    [self onResult:SSNativeAdvandedAdFailedToLoad message:[error localizedDescription]];
}

@end
