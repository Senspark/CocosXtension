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

#include <array>

#import "AdsAdmob.h"
#import <GADMAdapterAdColonyExtras.h>
#import <GADMAdapterAdColonyInitializer.h>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAdmob

@synthesize debug                       = __debug;
@synthesize strBannerID                 = __strBannerID;
@synthesize strInterstitialID           = __strInterstitialID;
@synthesize testDeviceIDs               = __TestDeviceIDs;
@synthesize strAdColonyRewardedAdZoneID = __strAdColonyRewardedAdZoneID;

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

#pragma mark Mediation Ads impl
- (void) initializeMediationAd {
    NSLog(@"Not require on iOS");
}

- (void) configMediationAdColony:(NSDictionary *)params
{
    //initialize AdColony SDK
    NSString* adColonyID                    = (NSString*) [params objectForKey:@"AdColonyAppID"];
    NSString* interstitialAdColonyZoneID    = (NSString*) [params objectForKey:@"AdColonyInterstitialAdID"];
    NSString* rewardedAdColonyZoneID        = (NSString*) [params objectForKey:@"AdColonyRewardedAdID"];
    self.strAdColonyRewardedAdZoneID        = rewardedAdColonyZoneID;

    if (nil != adColonyID) {
        [GADMAdapterAdColonyInitializer startWithAppID:adColonyID andZones: [NSArray arrayWithObjects:interstitialAdColonyZoneID, rewardedAdColonyZoneID, nil] andCustomID:nullptr];
    }
}

- (void) configMediationAdUnity:(NSDictionary *)params
{
    NSLog(@"No config is required for UnityAds");
}

- (void) configMediationAdVungle:(NSDictionary *)params
{
    NSLog(@"No config is required for Vungle");
}

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSDictionary*) devInfo {
    NSString* bannerId      = (NSString*) [devInfo objectForKey:@"AdmobID"];
    NSString* interstiailId = (NSString*) [devInfo objectForKey:@"AdmobInterstitialID"];
    
    if (bannerId == nil) {
        NSLog(@"WARNING: BannerID is nil");
    }
    
    if (interstiailId == nil) {
        NSLog(@"WARNING: IntestitialID is nil");
    }
    
    self.strBannerID        = bannerId;
    self.strInterstitialID  = interstiailId;
    
    _interstitialView   = nil;
    _bannerView         = nil;
}

- (void) showAds: (NSDictionary*) info position:(int) pos {
    if (self.strBannerID == nil || self.strBannerID.length == 0) {
        OUTPUT_LOG(@"configDeveloperInfo() not correctly invoked in Admob!");
        return;
    }


    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner: {
            NSString* strSize = [info objectForKey:@"AdmobSizeEnum"];
            int sizeEnum = [strSize intValue];
            [self showBanner:sizeEnum atPos:pos];
            break;
        }
    case kTypeFullScreen: {
            [self showInterstitial];
            break;
        }
    default:
        OUTPUT_LOG(@"The value of 'AdmobType' is wrong (should be 1 or 2)");
        break;
    }
}

- (void) hideAds: (NSDictionary*) info
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

- (void) showBanner: (int) sizeEnum atPos:(int) pos {
    const std::array<GADAdSize, 7> AdSizes {{
        kGADAdSizeBanner,
        kGADAdSizeLargeBanner,
        kGADAdSizeMediumRectangle,
        kGADAdSizeFullBanner,
        kGADAdSizeLeaderboard,
        kGADAdSizeSkyscraper,
        kGADAdSizeSmartBannerLandscape
    }};
    auto size = AdSizes.at(sizeEnum);
    
    if (nil != self.bannerView) {
        [self.bannerView removeFromSuperview];
        [self.bannerView release];
        self.bannerView = nil;
    }
    
    self.bannerView = [[GADBannerView alloc] initWithAdSize:size];
    self.bannerView.adUnitID = self.strBannerID;
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
    if (_interstitialView != nil) {
        [_interstitialView release];
    }
    self.interstitialView = [[GADInterstitial alloc] initWithAdUnitID:self.strInterstitialID];
    self.interstitialView.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        GADRequest* request = [GADRequest request];
        request.testDevices = [NSArray arrayWithArray:self.testDeviceIDs];
        
        [self.interstitialView loadRequest:request];
    });
}

- (void) showInterstitial
{
    NSLog(@"Interstitial view: %@", _interstitialView);
    if (!self.interstitialView || !self.interstitialView.isReady) {
        // Ad not ready to present.
        NSLog(@"ADMOB: Interstitial cannot show. It is not ready.");
        [self loadInterstitial];
    } else {
        [self.interstitialView presentFromRootViewController:[AdsWrapper getCurrentRootViewController]];
        [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsShown withMsg:@"Ads is shown!"];
    }
}

#pragma mark - Rewarded Video Ad

- (BOOL) hasRewardedAd {
    return [[GADRewardBasedVideoAd sharedInstance] isReady];
}

- (void) loadRewardedAd:(NSString *)adsID {

    [[GADRewardBasedVideoAd sharedInstance] setDelegate:self];
    GADRequest *request = [GADRequest request];
    [request setTestDevices: [NSArray arrayWithArray: self.testDeviceIDs]];

    if (self.strAdColonyRewardedAdZoneID.length > 0) {
        GADMAdapterAdColonyExtras *extras = [[GADMAdapterAdColonyExtras alloc] initWithZone: self.strAdColonyRewardedAdZoneID];
        [request registerAdNetworkExtras: extras];
    }

    [[GADRewardBasedVideoAd sharedInstance] loadRequest: request
                                           withAdUnitID: adsID];

}

- (void) showRewardedAd {
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:[AdsWrapper getCurrentRootViewController]];
    }
}

- (NSNumber*) getBannerWidthInPixel
{
    int ret = 0;
    if (self.bannerView) {
        ret = self.bannerView.frame.size.width;
    }
    return [NSNumber numberWithInt:ret];
}

- (NSNumber*) getBannerHeightInPixel
{
    int ret = 0;
    if (self.bannerView) {
        ret = self.bannerView.frame.size.height;
    }
    return [NSNumber numberWithInt:ret];
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
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsBannerReceived withMsg:@"Ads request received success!"];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
    AdsResultCode errorNo = AdsResultCode::kAdsUnknownError;
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
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsInterstitialReceived withMsg:@"Ads request received success!"];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    OUTPUT_LOG(@"Interstitial failed to load with error: %@", error.description);
    
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsUnknownError withMsg:error.description];
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
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kAdsDismissed withMsg:@"Interstital dismissed."];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    OUTPUT_LOG(@"Interstitial will leave application.");
}

#pragma mark - Rewarded Video Ad Delegate
- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoReceived withMsg:@"Reward based video ad is received."];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoShown withMsg:@"Opened reward based video ad."];
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoClosed withMsg:@"Reward based video ad is closed."];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage = [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type, [reward.amount doubleValue]];
    NSLog(@"%@", rewardMessage);
    // Reward the user for watching the video.
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    NSLog(@"Reward based video ad failed to load.");
    [AdsWrapper onAdsResult:self withRet:AdsResultCode::kVideoUnknownError withMsg:[NSString stringWithFormat:@"Reward based video ad failed to load with error: %@", error]];
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
        if ([_bannerView isHidden]) {
            [_bannerView setHidden: NO];
        }
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
