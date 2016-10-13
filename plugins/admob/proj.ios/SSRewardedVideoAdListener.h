//
//  SSRewardedAdListener.hpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

@class GADRewardBasedVideoAd;

#import <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>

#import "SSAdMobListenerProtocol.h"

@interface SSRewardedVideoAdListener
    : SSAdMobListenerProtocol <GADRewardBasedVideoAdDelegate>

@end
