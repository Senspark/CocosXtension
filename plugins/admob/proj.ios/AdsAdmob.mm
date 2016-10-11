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
#import "SSNativeExpressAdListener.h"
#import "SSAdColonyMediation.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AdsAdmob

@synthesize debug                           = __debug;
@synthesize strBannerID                     = __strBannerID;
@synthesize strInterstitialID               = __strInterstitialID;
@synthesize testDeviceIDs                   = __TestDeviceIDs;

- (id) init {
    self = [super init];
    if (self == nil) {
        return self;
    }

    nativeExpressAdListener_ =
        [[SSNativeExpressAdListener alloc] initWithAdsInterface:self];

    return self;
}

- (void) dealloc
{
    if (self.bannerAdView != nil) {
        [self.bannerAdView release];
        self.bannerAdView = nil;
    }

    if (self.interstitialAdView != nil) {
        [self.interstitialAdView release];
        self.interstitialAdView = nil;
    }
    
    if (self.testDeviceIDs != nil) {
        [self.testDeviceIDs release];
        self.testDeviceIDs = nil;
    }
    
    [nativeExpressAdListener_ release];
    nativeExpressAdListener_ = nil;
    
    [super dealloc];
}

#pragma mark Mediation Ads impl

- (void)configMediationAdColony:(NSDictionary*)params {
    // clang-format off
    NSString* appId                = [params objectForKey:@"AdColonyAppID"];
    NSString* interstitialAdZoneId = [params objectForKey:@"AdColonyInterstitialAdID"];
    NSString* rewardedAdZoneId     = [params objectForKey:@"AdColonyRewardedAdID"];
    // clang-format on

    // Reset old values.
    [self setAdColonyRewardedAdZoneId:nil];
    [self setAdColonyInterstitialAdZoneId:nil];

    if (appId != nil) {
        if ([SSAdColonyMediation isLinkedWithAdColony]) {
            NSArray* zones = [NSArray
                arrayWithObjects:interstitialAdZoneId, rewardedAdZoneId, nil];
            [SSAdColonyMediation startWithAppId:appId
                                       andZones:zones
                                    andCustomId:nil];

            // Assigns new values.
            [self setAdColonyInterstitialAdZoneId:interstitialAdZoneId];
            [self setAdColonyRewardedAdZoneId:rewardedAdZoneId];
        } else {
            NSLog(@"AdColony is not linked!");
        }
    }
}

#pragma mark InterfaceAds impl

- (void) configDeveloperInfo: (NSDictionary*) devInfo {
    NSLog(@"Deprecated: Use showBannerAd(adId) and loadInterstitialAd(adId) instead!");
    
    NSString* bannerId      = [devInfo objectForKey:@"AdmobID"];
    NSString* interstiailId = [devInfo objectForKey:@"AdmobInterstitialID"];
    
    if (bannerId == nil) {
        NSLog(@"WARNING: BannerID is nil");
    }
    
    if (interstiailId == nil) {
        NSLog(@"WARNING: IntestitialID is nil");
    }
    
    self.strBannerID        = bannerId;
    self.strInterstitialID  = interstiailId;
    
    _interstitialAdView   = nil;
    _bannerAdView         = nil;
}

- (void) showAds: (NSDictionary*) info position:(int) pos {
    NSLog(@"Deprecated: Use showBannerAd(adId) and showInterstitialAd instead!");
    
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
            [self _showBannerAd:[self strBannerID]
                           size:@(sizeEnum)
                       position:@(pos)];
            break;
        }
    case kTypeFullScreen: {
            [self showInterstitialAd];
            break;
        }
    default:
        OUTPUT_LOG(@"The value of 'AdmobType' is wrong (should be 1 or 2)");
        break;
    }
}

- (void) hideAds: (NSDictionary*) info
{
    NSLog(@"Deprecated: Use hideBannerAd(adId) instead!");
    
    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner:
        {
            [self hideBannerAd];
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

- (void)showBannerAd:(NSDictionary*)params {
    NSAssert([params count] == 3, @"Invalid number of params");

    NSString* adId = params[@"Param1"];
    NSNumber* size = params[@"Param2"];
    NSNumber* position = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([size isKindOfClass:[NSNumber class]], @"...");
    NSAssert([position isKindOfClass:[NSNumber class]], @"...");

    [self _showBannerAd:adId size:size position:position];
}

- (void)hideBannerAd {
    if ([self bannerAdView] != nil) {
        [[self bannerAdView] removeFromSuperview];
        [[self bannerAdView] release];
        [self setBannerAdView:nil];
        [self setBannerAdSize:GADAdSizeFromCGSize(CGSizeMake(0, 0))];
    }
}

- (void)_showBannerAd:(NSString* _Nonnull)adId
                 size:(NSNumber* _Nonnull)_size
             position:(NSNumber* _Nonnull)position {
    [self hideBannerAd];

    const std::array<GADAdSize, 7> AdSizes{
        {kGADAdSizeBanner, kGADAdSizeLargeBanner, kGADAdSizeMediumRectangle,
         kGADAdSizeFullBanner, kGADAdSizeLeaderboard, kGADAdSizeSkyscraper,
         [self getSmartBannerAdSize]}};
    auto size = AdSizes.at([_size unsignedIntegerValue]);
    [self setBannerAdSize:size];

    GADBannerView* bannerAdView = [[GADBannerView alloc] initWithAdSize:size];
    [bannerAdView setAdUnitID:adId];
    [bannerAdView setDelegate:self];
    [bannerAdView
        setRootViewController:[AdsWrapper getCurrentRootViewController]];
    [AdsWrapper addAdView:bannerAdView
                    atPos:(ProtocolAds::AdsPos)([position integerValue])];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    [bannerAdView loadRequest:request];

    [self setBannerAdView:bannerAdView];
}

- (void)loadInterstitial {
    [self loadInterstitialAd:[self strInterstitialID]];
}

- (void)loadInterstitialAd:(NSString* _Nonnull)adId {
    if ([self interstitialAdView] != nil) {
        [[self interstitialAdView] release];
    }
    GADInterstitial* interstitialAdView =
        [[GADInterstitial alloc] initWithAdUnitID:adId];
    [interstitialAdView setDelegate:self];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    if ([SSAdColonyMediation isLinkedWithAdColony] &&
        [[self adColonyInterstitialAdZoneId] length] > 0) {
        id<GADAdNetworkExtras> extras = [SSAdColonyMediation
            extrasWithZoneId:[self adColonyInterstitialAdZoneId]];
        [request registerAdNetworkExtras:extras];
    }
    [interstitialAdView loadRequest:request];
    
    [self setInterstitialAdView:interstitialAdView];
}

- (void)showInterstitialAd {
    NSLog(@"Interstitial view: %@", [self interstitialAdView]);

    if (not[self hasInterstitialAd]) {
        // Ad not ready to present.
        NSLog(@"ADMOB: Interstitial cannot show. It is not ready.");
        [self loadInterstitial];
    } else {
        [[self interstitialAdView]
            presentFromRootViewController:
                [AdsWrapper getCurrentRootViewController]];
        [AdsWrapper onAdsResult:self
                        withRet:AdsResultCode::kAdsShown
                        withMsg:@"Ads is shown!"];
    }
}

- (BOOL)hasInterstitialAd {
    return [[self interstitialAdView] isReady];
}

- (GADAdSize) createAdSize:(NSNumber* _Nonnull) width
                    height:(NSNumber* _Nonnull) height {
    UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];
    if ([width intValue] == -1) {
        // Full width.
        if ([height intValue] == -2) {
            // Auto height.
            // Smart banner.
            return [self getSmartBannerAdSize];
        }
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return GADAdSizeFullWidthLandscapeWithHeight([height intValue]);
        }
        return GADAdSizeFullWidthPortraitWithHeight([height intValue]);
    }
    return GADAdSizeFromCGSize(CGSizeMake([width intValue], [height intValue]));
}

- (void)_showNativeExpressAd:(NSString* _Nonnull)adUnitId
                       width:(NSNumber* _Nonnull)width
                      height:(NSNumber* _Nonnull)height
                    position:(NSNumber* _Nonnull)position {
    [self hideNativeExpressAd];

    GADAdSize adSize = [self createAdSize:width height:height];
    GADNativeExpressAdView* view =
        [[[GADNativeExpressAdView alloc] initWithAdSize:adSize] autorelease];
    if (view == nil) {
        NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
        return;
    }

    UIViewController* controller = [AdsWrapper getCurrentRootViewController];

    [view setAdUnitID:adUnitId];
    [view setDelegate:nativeExpressAdListener_];
    [view setRootViewController:controller];

    [AdsWrapper addAdView:view atPos:(ProtocolAds::AdsPos)[position intValue]];
    [self setNativeExpressAdView:view];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    [view loadRequest:request];
}

- (void)showNativeExpressAd:(NSDictionary* _Nonnull)params {
    NSAssert([params count] == 4, @"Invalid number of params");

    NSString* adUnitId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];
    NSNumber* position = params[@"Param4"];

    NSAssert([adUnitId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");
    NSAssert([position isKindOfClass:[NSNumber class]], @"...");

    [self _showNativeExpressAd:adUnitId
                         width:width
                        height:height
                      position:position];
}

- (void)_showNativeExpressAd:(NSString* _Nonnull)adUnitId
                       width:(NSNumber* _Nonnull)width
                      height:(NSNumber* _Nonnull)height
                      deltaX:(NSNumber* _Nonnull)deltaX
                      deltaY:(NSNumber* _Nonnull)deltaY {
    [self hideNativeExpressAd];

    GADAdSize adSize = [self createAdSize:width height:height];
    GADNativeExpressAdView* view =
        [[[GADNativeExpressAdView alloc] initWithAdSize:adSize] autorelease];
    if (view == nil) {
        NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
        return;
    }

    UIViewController* controller = [AdsWrapper getCurrentRootViewController];

    [view setAdUnitID:adUnitId];
    [view setDelegate:nativeExpressAdListener_];
    [view setRootViewController:controller];

    [AdsWrapper addAdView:view withDeltaX:deltaX withDeltaY:deltaY];
    [self setNativeExpressAdView:view];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    [view loadRequest:request];
}

- (void)showNativeExpressAdWithDeltaPosition:(NSDictionary* _Nonnull)params {
    NSAssert([params count] == 5, @"Invalid number of params");

    NSString* adUnitId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];
    NSNumber* deltaX = params[@"Param4"];
    NSNumber* deltaY = params[@"Param5"];

    NSAssert([adUnitId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");
    NSAssert([deltaX isKindOfClass:[NSNumber class]], @"...");
    NSAssert([deltaY isKindOfClass:[NSNumber class]], @"...");

    [self _showNativeExpressAd:adUnitId
                         width:width
                        height:height
                        deltaX:deltaX
                        deltaY:deltaY];
}

- (void)hideNativeExpressAd {
    if ([self nativeExpressAdView] != nil) {
        [[self nativeExpressAdView] removeFromSuperview];
        [self setNativeExpressAdView:nil];
    }
}

- (GADBannerView* _Nullable)createDummySmartBanner {
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self getSmartBannerAdSize]];
    return [banner autorelease];
}

- (NSNumber* _Nonnull)getSizeInPixels:(NSNumber* _Nonnull)size_ {
    int size = [size_ intValue];
    if (size == -2) {
        return [self getAutoHeightInPixels];
    }
    if (size == -1) {
        return [self getFullWidthInPixels];
    }
    GADAdSize adSize = GADAdSizeFromCGSize(CGSizeMake(size, size));
    GADBannerView* banner =
        [[[GADBannerView alloc] initWithAdSize:adSize] autorelease];
    if (banner == nil) {
        NSLog(@"%s: invalid ad size", __PRETTY_FUNCTION__);
        return @(0);
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.height * scale);
}

- (NSNumber* _Nonnull)getAutoHeightInPixels {
    GADBannerView* banner = [self createDummySmartBanner];
    if (banner == nil) {
        NSAssert(NO, @"...");
        return @(0);
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.height * scale);
}

- (NSNumber* _Nonnull)getFullWidthInPixels {
    GADBannerView* banner = [self createDummySmartBanner];
    if (banner == nil) {
        NSAssert(NO, @"...");
        return @(0);
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.width * scale);
}

#pragma mark - Rewarded Video Ad

- (void)loadRewardedAd:(NSString* _Nonnull)adId {
    [[GADRewardBasedVideoAd sharedInstance] setDelegate:self];
    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];

    if ([SSAdColonyMediation isLinkedWithAdColony] &&
        [[self adColonyRewardedAdZoneId] length] > 0) {
        id<GADAdNetworkExtras> extras = [SSAdColonyMediation
            extrasWithZoneId:[self adColonyRewardedAdZoneId]];
        [request registerAdNetworkExtras:extras];
    }

    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:adId];
}

- (void)showRewardedAd {
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        [[GADRewardBasedVideoAd sharedInstance]
            presentFromRootViewController:
                [AdsWrapper getCurrentRootViewController]];
    }
}

- (BOOL)hasRewardedAd {
    return [[GADRewardBasedVideoAd sharedInstance] isReady];
}

- (NSNumber*)getBannerWidthInPixel {
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.width * scale);
}

- (NSNumber*)getBannerHeightInPixel {
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.height * scale);
}

#pragma mark interface for Admob SDK

- (void)addTestDevice:(NSString*)deviceID {
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
                         self.bannerAdView.frame = CGRectMake(windowBounds.size.width - self.bannerAdView.frame.size.width,
                                                            windowBounds.size.height,
                                                            self.bannerAdView.frame.size.width,
                                                            self.bannerAdView.frame.size.height);
                     }];
}

- (void) slideUpBannerAds {
    OUTPUT_LOG(@"Show Banner Ads!");
        if ([_bannerAdView isHidden]) {
            [_bannerAdView setHidden: NO];
        }
    CGRect windowBounds = [[[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]] bounds];
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.bannerAdView.frame = CGRectMake(windowBounds.size.width - self.bannerAdView.frame.size.width,
                                                            windowBounds.size.height - self.bannerAdView.frame.size.height,
                                                            self.bannerAdView.frame.size.width,
                                                            self.bannerAdView.frame.size.height);

                     }];

}

/// Retrieves the size of the smart banner depends on the orientation of the
/// design resolution.
- (GADAdSize)getSmartBannerAdSize {
    UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];

    return UIInterfaceOrientationIsLandscape(orientation)
               ? kGADAdSizeSmartBannerLandscape
               : kGADAdSizeSmartBannerPortrait;
}

@end
