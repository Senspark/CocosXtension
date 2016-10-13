//
//  NativeExpressAdListener.h
//  PluginAdmob
//
//  Created by Zinge on 6/22/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import <GoogleMobileAds/GADNativeExpressAdViewDelegate.h>

#import "SSAdMobListenerProtocol.h"

@interface SSNativeExpressAdListener
    : SSAdMobListenerProtocol <GADNativeExpressAdViewDelegate>

@end
