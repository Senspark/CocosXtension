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

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAdmob

@synthesize debug           = __debug;
@synthesize strPublishID    = __strPublishID;
@synthesize testDeviceIDs   = __TestDeviceIDs;

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
    NSString* adsId = (NSString*) [devInfo objectForKey:@"AdmobID"];

    if (nil == adsId) {
        OUTPUT_LOG(@"Null ads Id at configure time.");
        return;
    }

    OUTPUT_LOG(@"Configure with adsId: %@", adsId);

    self.strPublishID = adsId;
}

- (void) showAds: (NSMutableDictionary*) info position:(int) pos
{
    if (self.strPublishID == nil ||
        [self.strPublishID length] == 0) {
        OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in Admob!");
        return;
    }


    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner:
        {
            NSString* strSize = [info objectForKey:@"AdmobSizeEnum"];
            int sizeEnum = [strSize intValue];
            [self showBanner:sizeEnum atPos:pos];
            break;
        }
    case kTypeFullScreen:
        {
            [self showInterstitial];
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
    self.bannerView.adUnitID = self.strPublishID;
    self.bannerView.delegate = self;
    [self.bannerView setRootViewController:[AdsWrapper getCurrentRootViewController]];
    [AdsWrapper addAdView:self.bannerView atPos:(ProtocolAds::AdsPos)pos];
    
    GADRequest* request = [GADRequest request];
    request.testDevices = [NSArray arrayWithArray:self.testDeviceIDs];
    [self.bannerView loadRequest:request];
}

- (BOOL) hasInterstitial {
    return [self.interstitialView isReady];
}

- (void) loadInterstitial
{
    self.interstitialView = [[GADInterstitial alloc] init];
    self.interstitialView.adUnitID = self.strPublishID;
    self.interstitialView.delegate = self;

    GADRequest* request = [GADRequest request];
    request.testDevices = [NSArray arrayWithArray:self.testDeviceIDs];
    [self.interstitialView loadRequest:request];
}

- (void) showInterstitial
{
    NSLog(@"Interstitial view: %@", _interstitialView);
    if (!self.interstitialView || !self.interstitialView.isReady) {
        // Ad not ready to present.
        NSLog(@"ADMOB: Interstitial cannot show. It is not ready.");
    } else {
        [self.interstitialView presentFromRootViewController:[AdsWrapper getCurrentRootViewController]];
        [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsShown withMsg:@"Ads is shown!"];
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
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsReceived withMsg:@"Ads request received success!"];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
    AdsResultCode errorNo = AdsResultCode::kUnknownError;
    switch ([error code]) {
    case kGADErrorNetworkError:
        errorNo = AdsResultCode::kNetworkError;
        break;
    default:
        break;
    }
    [AdsWrapper onAdsResult:self withRet:errorNo withMsg:[error localizedDescription]];
}

#pragma mark GADInterstitialDelegate impl

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial ad was loaded. Can present now.");
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsReceived withMsg:@"Ads request received success!"];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    OUTPUT_LOG(@"Interstitial failed to load with error: %@", error.description);
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kUnknownError withMsg:error.description];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsShown withMsg:@"Interstitial is showing"];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial will dismiss.");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial dismissed")
    [self loadInterstitial];
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsDismissed withMsg:@"Interstital dismissed."];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial will leave application.");
}

#pragma mark - Animation banner ads
- (void) slideDownBannerAds {
    CGRect windowBounds = [[[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]] bounds];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.bannerView.frame = CGRectMake(windowBounds.size.width - self.bannerView.frame.size.width,
                                                            windowBounds.size.height,
                                                            self.bannerView.frame.size.width,
                                                            self.bannerView.frame.size.height);
                     }];
}

- (void) slideUpBannerAds {
    OUTPUT_LOG(@"Show Banner Ads!");
    CGRect windowBounds = [[[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]] bounds];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.bannerView.frame = CGRectMake(windowBounds.size.width - self.bannerView.frame.size.width,
                                                            windowBounds.size.height - self.bannerView.frame.size.height,
                                                            self.bannerView.frame.size.width,
                                                            self.bannerView.frame.size.height);

                     }];

}
@end
