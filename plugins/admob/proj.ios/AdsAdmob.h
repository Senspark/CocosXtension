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

typedef enum {
    kTypeBanner = 1,
    kTypeFullScreen,
} AdmobType;

@interface AdsAdmob : NSObject <InterfaceAds, GADBannerViewDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate>
{
}

@property BOOL debug;

@property (copy, nonatomic) NSString* strPublishID;
@property (copy, nonatomic) NSString* strAdColonyRewardedAdZoneID;

@property (assign, nonatomic) GADBannerView* bannerView;
@property (assign, nonatomic) GADInterstitial* interstitialView;
@property (assign, nonatomic) NSMutableArray* testDeviceIDs;
@property (assign, nonatomic) int slideUpTimePeriod;
@property (assign, nonatomic) int slideDownTimePeriod;

/**
 interface for Admob SDK
 */
- (void) addTestDevice: (NSString*) deviceID;
- (void) slideUpBannerAds;
- (void) slideDownBannerAds;
- (void) loadInterstitial;
- (BOOL) hasInterstitial;

- (BOOL) hasRewardedAd;
- (void) loadRewardedAd: (NSString*) adsID;
- (void) showRewardedAd;

- (void) configMediationAdColony: (NSDictionary* __nullable) params;
- (void) configMediationAdVungle: (NSDictionary* __nullable) params;
- (void) configMediationAdUnity: (NSDictionary* __nullable) params;

@end
