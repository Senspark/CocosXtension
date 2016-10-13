//
//  SSInterstitialAdListener.hpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import <GoogleMobileAds/GADInterstitialDelegate.h>

#import "SSAdMobListenerProtocol.h"

@interface SSInterstitialAdListener
    : SSAdMobListenerProtocol <GADInterstitialDelegate>

@end
