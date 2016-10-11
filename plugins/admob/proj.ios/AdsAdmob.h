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

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <GoogleMobileAds/GADAdSize.h>

#import "InterfaceAds.h"
#import "AdsWrapper.h"

@class SSNativeExpressAdListener;

typedef enum {
    kTypeBanner = 1,
    kTypeFullScreen,
} AdmobType;

@interface AdsAdmob
    : NSObject <InterfaceAds, GADBannerViewDelegate, GADInterstitialDelegate,
                GADRewardBasedVideoAdDelegate> {

    SSNativeExpressAdListener* nativeExpressAdListener_;
}

@property BOOL debug;

// clang-format off
@property (nonatomic, retain, nullable) NSString* strBannerID DEPRECATED_ATTRIBUTE;
@property (nonatomic, retain, nullable) NSString* strInterstitialID DEPRECATED_ATTRIBUTE;

@property (nonatomic, copy, nullable) NSString* adColonyInterstitialAdZoneId;
@property (nonatomic, copy, nullable) NSString* adColonyRewardedAdZoneId;

@property (nonatomic, assign, nullable) GADBannerView* bannerAdView;
@property (nonatomic, assign, nullable) GADInterstitial* interstitialAdView;
@property (nonatomic, assign, nullable) GADNativeExpressAdView* nativeExpressAdView;

@property (nonatomic, assign, nullable) NSMutableArray* testDeviceIDs;

@property (nonatomic) GADAdSize bannerAdSize;

@property (nonatomic, assign) int slideUpTimePeriod;
@property (nonatomic, assign) int slideDownTimePeriod;
// clang-format on

/**
 interface for Admob SDK
 */
- (void)addTestDevice:(NSString* _Nonnull)deviceID;
- (void)slideUpBannerAds;
- (void)slideDownBannerAds;

- (void)showBannerAd:(NSDictionary* _Nonnull)params;
- (void)hideBannerAd;

- (void)showNativeExpressAd:(NSDictionary* _Nonnull)params;
- (void)showNativeExpressAdWithDeltaPosition:(NSDictionary* _Nonnull)params;
- (void)hideNativeExpressAd;

- (void)loadInterstitial DEPRECATED_ATTRIBUTE;
- (void)loadInterstitialAd:(NSString* _Nonnull)adId;
- (void)showInterstitialAd;
- (BOOL)hasInterstitialAd;

- (void)loadRewardedAd:(NSString* _Nonnull)adID;
- (void)showRewardedAd;
- (BOOL)hasRewardedAd;

- (NSNumber* _Nonnull)getSizeInPixels:(NSNumber* _Nonnull)size;
- (NSNumber* _Nonnull)getAutoHeightInPixels;
- (NSNumber* _Nonnull)getFullWidthInPixels;

- (void)configMediationAdColony:(NSDictionary* __nullable)params;

@end
