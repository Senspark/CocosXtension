/****************************************************************************
 Copyright (c) 2013 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import <Foundation/Foundation.h>

#import "InterfaceAds.h"

@class SSBannerAdListener;
@class SSNativeExpressAdListener;
@class SSInterstitialAdListener;
@class SSRewardedVideoAdListener;

typedef enum {
    kTypeBanner = 1,
    kTypeFullScreen,
} AdmobType;

@interface AdsAdmob : NSObject <InterfaceAds> {
    SSBannerAdListener* bannerAdListener_;
    SSNativeExpressAdListener* nativeExpressAdListener_;
    SSInterstitialAdListener* interstitialAdListener_;
    SSRewardedVideoAdListener* rewardedVideoAdListener_;

    NSMutableDictionary<NSString*, UIView*>* adViews_;
    NSMutableDictionary<NSString*, NSValue*>* adSizes_;
}

@property (nonatomic) BOOL debug;

// clang-format off
@property (nonatomic, copy, nullable) NSString* strBannerID DEPRECATED_ATTRIBUTE;
@property (nonatomic, copy, nullable) NSString* strInterstitialID DEPRECATED_ATTRIBUTE;
// clang-format on

@property (nonatomic, retain, nullable) NSMutableArray* testDeviceIDs;

@property (nonatomic, copy, nullable) NSString* adColonyInterstitialAdZoneId;
@property (nonatomic, copy, nullable) NSString* adColonyRewardedAdZoneId;

@property (nonatomic, assign, nullable) GADInterstitial* interstitialAdView;

/**
 interface for Admob SDK
 */
- (void)addTestDevice:(NSString* _Nonnull)deviceId;
- (void)configMediationAdColony:(NSDictionary* _Nonnull)params;

- (void)createBannerAd:(NSDictionary* _Nonnull)params;
- (void)createNativeExpressAd:(NSDictionary* _Nonnull)params;
- (void)destroyAd:(NSString* _Nonnull)adId;
- (void)showAd:(NSString* _Nonnull)adId;
- (void)hideAd:(NSString* _Nonnull)adId;
- (void)moveAd:(NSDictionary* _Nonnull)params;

- (void)loadInterstitial DEPRECATED_ATTRIBUTE;

- (void)showInterstitialAd;
- (void)loadInterstitialAd:(NSString* _Nonnull)adId;
- (BOOL)hasInterstitialAd;

- (void)showRewardedAd;
- (void)loadRewardedAd:(NSString* _Nonnull)adID;
- (BOOL)hasRewardedAd;

- (NSNumber* _Nonnull)getSizeInPixels:(NSNumber* _Nonnull)size;
- (NSNumber* _Nonnull)getRealScreenWidthInPixels;
- (NSNumber* _Nonnull)getRealScreenHeightInPixels;

@end
