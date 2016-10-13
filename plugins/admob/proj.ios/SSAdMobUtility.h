//
//  SSAdMobUtility.h
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

@class UIViewController;

typedef NS_ENUM(NSInteger, SSAdPosition) {
    SSAdPositionCenter,
    SSAdPositionTop,
    SSAdPositionTopLeft,
    SSAdPositionTopRight,
    SSAdPositionBottom,
    SSAdPositionBottomLeft,
    SSAdPositionBottomRight
};

typedef NS_ENUM(NSInteger, SSBannerAdCode) {
    // clang-format off
    SSBannerAdLoaded                    = 40,
    SSBannerAdFailedToLoad              = 41,
    SSBannerAdOpened                    = 42,
    SSBannerAdClosed                    = 43,
    SSBannerAdLeftApplication           = 44,
    // clang-format on
};

typedef NS_ENUM(NSInteger, SSNativeExpressAdCode) {
    // clang-format off
    SSNativeExpressAdLoaded             = 50,
    SSNativeExpressAdFailedToLoad       = 51,
    SSNativeExpressAdOpended            = 52,
    SSNativeExpressAdClosed             = 53,
    SSNativeExpressAdLeftApplication    = 54,
    // clang-format on
};

typedef NS_ENUM(NSInteger, SSInterstitialAdCode) {
    // clang-format off
    SSInterstitialAdLoaded              = 60,
    SSInterstitialAdFailedToLoad        = 61,
    SSInterstitialAdOpened              = 62,
    SSInterstitialAdClosed              = 63,
    SSInterstitialAdLeftApplication     = 64,
    // clang-format on
};

typedef NS_ENUM(NSInteger, SSRewardedAdCode) {
    // clang-format off
    SSRewardedVideoAdLoaded              = 70,
    SSRewardedVideoAdFailedToLoad        = 71,
    SSRewardedVideoAdOpended             = 72,
    SSRewardedVideoAdStarted             = 73,
    SSRewardedVideoAdClosed              = 74,
    SSRewardedVideoAdRewarded            = 75,
    SSRewardedVideoAdLeftApplication     = 76,
    // clang-format on
};

@interface SSAdMobUtility : NSObject

+ (UIViewController* _Nullable)getCurrentRootViewController;

@end
