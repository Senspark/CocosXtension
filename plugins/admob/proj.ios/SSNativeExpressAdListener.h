//
//  NativeExpressAdListener.h
//  PluginAdmob
//
//  Created by Zinge on 6/22/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import <GoogleMobileAds/GADNativeExpressAdViewDelegate.h>

@protocol InterfaceAds;

@interface SSNativeExpressAdListener : NSObject<GADNativeExpressAdViewDelegate>;

- (id _Nullable) initWithAdsInterface:(id _Nonnull) interface;

@property (nonatomic, readonly, nonnull) id interface;

@end