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

#import "AdsAdmob.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAdmob

@synthesize debug = __debug;
@synthesize strBannerID = __BannerID;
@synthesize strInterstitialID = __InterstitialID;
@synthesize testDeviceIDs = __TestDeviceIDs;

- (void) dealloc
{
    if (self.bannerView != nil) {
        [self.bannerView release];
        self.bannerView = nil;
    }

    if (self.interstitialView != nil) {
        [self.interstitialView release];
        self.interstitialView = nil;
    }
    
    if (self.testDeviceIDs != nil) {
        [self.testDeviceIDs release];
        self.testDeviceIDs = nil;
    }
    
    [super dealloc];
}

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    self.strBannerID = (NSString*) [devInfo objectForKey:@"AdmobBannerID"];
    self.strInterstitialID = (NSString*) [devInfo objectForKey:@"AdmobInterstitialID"];
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    

    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner:
        {
            if (self.strBannerID == nil ||
                [self.strBannerID length] == 0) {
                OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in Admob!");
                return;
            }
            
            NSString* strSize = [info objectForKey:@"AdmobSizeEnum"];
            int sizeEnum = [strSize intValue];
            [self showBanner:sizeEnum atPos:pos];
            break;
        }
    case kTypeFullScreen:
        {
            if (self.strInterstitialID == nil ||
                [self.strInterstitialID length] == 0) {
                OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in Admob!");
                return;
            }
            
            [self loadInterstitial];
            break;
        }
    default:
        OUTPUT_LOG(@"The value of 'AdmobType' is wrong (should be 1 or 2)");
        break;
    }
}

- (void) hideAds: (NSMutableDictionary*) info
{
    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner:
        {
            if (nil != self.bannerView) {
                [self.bannerView removeFromSuperview];
                [self.bannerView release];
                self.bannerView = nil;
            }
            break;
        }
    case kTypeFullScreen:
        OUTPUT_LOG(@"Now not support full screen view in Admob");
        break;
    default:
        OUTPUT_LOG(@"The value of 'AdmobType' is wrong (should be 1 or 2)");
        break;
    }
}

- (void) queryPoints
{
    OUTPUT_LOG(@"Admob not support query points!");
}

- (void) spendPoints: (int) points
{
    OUTPUT_LOG(@"Admob not support spend points!");
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    self.debug = isDebugMode;
}

- (NSString*) getSDKVersion
{
    return @"7.3.1";
}

- (NSString*) getPluginVersion
{
    return @"0.3.0";
}

- (void) showBanner: (int) sizeEnum atPos:(int) pos
{
    GADAdSize size = kGADAdSizeBanner;
    switch (sizeEnum) {
        case kSizeBanner:
            size = kGADAdSizeBanner;
            break;
        case kSizeIABMRect:
            size = kGADAdSizeMediumRectangle;
            break;
        case kSizeIABBanner:
            size = kGADAdSizeFullBanner;
            break;
        case kSizeIABLeaderboard:
            size = kGADAdSizeLeaderboard;
            break;
        case kSizeSkyscraper:
            size = kGADAdSizeSkyscraper;
            break;
        default:
            break;
    }
    if (nil != self.bannerView) {
        [self.bannerView removeFromSuperview];
        [self.bannerView release];
        self.bannerView = nil;
    }
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:size];
    self.bannerView.adUnitID = self.strBannerID;
    self.bannerView.delegate = self;
    [self.bannerView setRootViewController:[AdsWrapper getCurrentRootViewController]];
    [AdsWrapper addAdView:self.bannerView atPos:pos];
    
    GADRequest* request = [GADRequest request];
    request.testDevices = [NSArray arrayWithArray:self.testDeviceIDs];
    [self.bannerView loadRequest:request];
}

- (void) loadInterstitial
{
    self.interstitialView = [[GADInterstitial alloc] initWithAdUnitID:self.strInterstitialID];
    self.interstitialView.delegate = self;

    GADRequest* request = [GADRequest request];
    request.testDevices = [NSArray arrayWithArray:self.testDeviceIDs];
    [self.interstitialView loadRequest:request];
}

- (void) showInterstitial
{
    if (!self.interstitialView || !self.interstitialView.isReady) {
        // Ad not ready to present.
        OUTPUT_LOG(@"Admob interstitial not loaded.");
    } else {
        [self.interstitialView presentFromRootViewController:[AdsWrapper getCurrentRootViewController]];
        [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"Ads is shown!"];
    }
}

#pragma mark interface for Admob SDK

- (void) addTestDevice: (NSString*) deviceID
{
    if (nil == self.testDeviceIDs) {
        self.testDeviceIDs = [[NSMutableArray alloc] init];
        [self.testDeviceIDs addObject:kDFPSimulatorID];
    }
    
    [self.testDeviceIDs addObject:deviceID];
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad");
    [AdsWrapper onAdsResult:self withRet:kAdsReceived withMsg:@"Ads request received success!"];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
    int errorNo = kUnknownError;
    switch ([error code]) {
    case kGADErrorNetworkError:
        errorNo = kNetworkError;
        break;
    default:
        break;
    }
    [AdsWrapper onAdsResult:self withRet:errorNo withMsg:[error localizedDescription]];
}

#pragma mark GADInterstitialDelegate impl

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial ad was loaded. Can present now.");
    [AdsWrapper onAdsResult:self withRet:kAdsReceived withMsg:@"Ads request received success!"];
    [self showInterstitial];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    OUTPUT_LOG(@"Interstitial failed to load with error: %@", error.description);
    [AdsWrapper onAdsResult:self withRet:kUnknownError withMsg:error.description];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [AdsWrapper onAdsResult:self withRet:kAdsShown withMsg:@"Interstitial is showing"];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial will dismiss.");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial dismissed")
    self.interstitialView = nil;
    [AdsWrapper onAdsResult:self withRet:kAdsDismissed withMsg:@"Interstital dismissed."];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial will leave application.");
}

@end
