//
//  SSNativeAdvancedAdListener.h
//  PluginAdmob
//
//  Created by Duc Nguyen on 4/17/17.
//  Copyright © 2017 cocos2d-x. All rights reserved.
//

#import <GoogleMobileAds/GADNativeAppInstallAd.h>
#import <GoogleMobileAds/GADNativeContentAd.h>

#import "SSAdMobListenerProtocol.h"

@interface SSNativeAdvancedAdListener : SSAdMobListenerProtocol<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>

@end
