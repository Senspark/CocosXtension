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

#define OUTPUT_LOG(...)                                                        \
    if (self.debug)                                                            \
        NSLog(__VA_ARGS__);

@implementation AdsAdmob

@synthesize debug = __debug;
@synthesize strBannerID = __strBannerID;
@synthesize strInterstitialID = __strInterstitialID;

- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }

    nativeExpressAdListener_ =
        [[SSNativeExpressAdListener alloc] initWithAdsInterface:self];

    return self;
}

- (void)dealloc {
    [self hideBannerAd];
    [self hideNativeExpressAd];
    [self _removeInterstitialAd];
    [self setTestDeviceIDs:nil];

    [nativeExpressAdListener_ release];
    nativeExpressAdListener_ = nil;

    [super dealloc];
}

- (void)addTestDevice:(NSString*)deviceId {
    if ([self testDeviceIDs] == nil) {
        [self setTestDeviceIDs:[NSMutableArray array]];
        [[self testDeviceIDs] addObject:kDFPSimulatorID];
    }

    [[self testDeviceIDs] addObject:deviceId];
}

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

- (void)configDeveloperInfo:(NSDictionary*)devInfo {
    NSLog(@"Deprecated: Use showBannerAd(adId) and loadInterstitialAd(adId) "
          @"instead!");

    NSString* bannerId = [devInfo objectForKey:@"AdmobID"];
    NSString* interstiailId = [devInfo objectForKey:@"AdmobInterstitialID"];

    if (bannerId == nil) {
        NSLog(@"WARNING: BannerID is nil");
    }

    if (interstiailId == nil) {
        NSLog(@"WARNING: IntestitialID is nil");
    }

    self.strBannerID = bannerId;
    self.strInterstitialID = interstiailId;

    _interstitialAdView = nil;
    _bannerAdView = nil;
}

- (void)showAds:(NSDictionary*)info position:(int)pos {
    NSLog(
        @"Deprecated: Use showBannerAd(adId) and showInterstitialAd instead!");

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
        [self _showBannerAd:[self strBannerID] size:@(sizeEnum)];
        [self _moveAd:[self bannerAdView] position:@(pos)];
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

- (void)hideAds:(NSDictionary*)info {
    NSLog(@"Deprecated: Use hideBannerAd(adId) instead!");

    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner: {
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

- (void)queryPoints {
    OUTPUT_LOG(@"Admob not support query points!");
}

- (void)spendPoints:(int)points {
    OUTPUT_LOG(@"Admob not support spend points!");
}

- (void)setDebugMode:(BOOL)isDebugMode {
    self.debug = isDebugMode;
}

- (NSString*)getSDKVersion {
    return @"7.3.1";
}

- (NSString*)getPluginVersion {
    return @"0.3.0";
}

#pragma mark - Banner ad

- (void)showBannerAd:(NSDictionary*)params {
    NSAssert([params count] == 3, @"Invalid number of params");

    NSString* adId = params[@"Param1"];
    NSNumber* size = params[@"Param2"];
    NSNumber* position = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([size isKindOfClass:[NSNumber class]], @"...");
    NSAssert([position isKindOfClass:[NSNumber class]], @"...");

    [self _showBannerAd:adId size:size];
    [self _moveAd:[self bannerAdView] position:position];
}

- (void)_showBannerAd:(NSString* _Nonnull)adId size:(NSNumber* _Nonnull)_size {
    [self hideBannerAd];

    const std::array<GADAdSize, 7> AdSizes{
        {kGADAdSizeBanner, kGADAdSizeLargeBanner, kGADAdSizeMediumRectangle,
         kGADAdSizeFullBanner, kGADAdSizeLeaderboard, kGADAdSizeSkyscraper,
         [self _getSmartBannerAdSize]}};
    auto size = AdSizes.at([_size unsignedIntegerValue]);
    [self setBannerAdSize:size];

    GADBannerView* view =
        [[[GADBannerView alloc] initWithAdSize:size] autorelease];
    [view setAdUnitID:adId];
    [view setDelegate:self];

    UIViewController* controller = [AdsWrapper getCurrentRootViewController];
    [view setRootViewController:controller];
    [[controller view] addSubview:view];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    [view loadRequest:request];

    [self setBannerAdView:view];
}

- (void)hideBannerAd {
    if ([self _hasBannerAd]) {
        [[self bannerAdView] removeFromSuperview];
        [self setBannerAdView:nil];
    }
}

- (void)moveBannerAd:(NSDictionary* _Nonnull)params {
    NSAssert([params count] == 2, @"...");

    NSNumber* x = params[@"Param1"];
    NSNumber* y = params[@"Param2"];

    NSAssert([x isKindOfClass:[NSNumber class]], @"...");
    NSAssert([y isKindOfClass:[NSNumber class]], @"...");

    [self _moveBannerAd:x y:y];
}

- (void)_moveBannerAd:(NSNumber* _Nonnull)x y:(NSNumber* _Nonnull)y {
    if ([self bannerAdView] != nil) {
        [self _moveAd:[self bannerAdView] x:x y:y];
    }
}

- (BOOL)_hasBannerAd {
    return [self bannerAdView] != nil;
}

#pragma mark - Native express ad

- (void)showNativeExpressAd:(NSDictionary* _Nonnull)params {
    NSAssert(4 <= [params count] && [params count] <= 5,
             @"Invalid number of params");

    NSString* adUnitId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];

    NSAssert([adUnitId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");

    [self _showNativeExpressAd:adUnitId width:width height:height];

    if ([params count] == 4) {
        NSNumber* position = params[@"Param4"];
        NSAssert([position isKindOfClass:[NSNumber class]], @"...");
        [self _moveAd:[self nativeExpressAdView] position:position];
    } else {
        NSNumber* x = params[@"Param4"];
        NSNumber* y = params[@"Param5"];
        NSAssert([x isKindOfClass:[NSNumber class]], @"...");
        NSAssert([y isKindOfClass:[NSNumber class]], @"...");
        [self _moveAd:[self nativeExpressAdView] x:x y:y];
    }
}

- (void)_showNativeExpressAd:(NSString* _Nonnull)adUnitId
                       width:(NSNumber* _Nonnull)width
                      height:(NSNumber* _Nonnull)height {
    [self hideNativeExpressAd];

    GADAdSize adSize = [self _createAdSize:width height:height];
    GADNativeExpressAdView* view =
        [[[GADNativeExpressAdView alloc] initWithAdSize:adSize] autorelease];
    if (view == nil) {
        NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
        return;
    }

    [view setAdUnitID:adUnitId];
    [view setDelegate:nativeExpressAdListener_];

    UIViewController* controller = [AdsWrapper getCurrentRootViewController];
    [view setRootViewController:controller];
    [[controller view] addSubview:view];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    [view loadRequest:request];

    [self setNativeExpressAdView:view];
}

- (void)hideNativeExpressAd {
    if ([self _hasNativeExpressAd]) {
        [[self nativeExpressAdView] removeFromSuperview];
        [self setNativeExpressAdView:nil];
    }
}

- (void)moveNativeExpressAd:(NSDictionary*)params {
    NSAssert([params count] == 2, @"...");

    NSNumber* x = params[@"Param1"];
    NSNumber* y = params[@"Param2"];

    NSAssert([x isKindOfClass:[NSNumber class]], @"...");
    NSAssert([y isKindOfClass:[NSNumber class]], @"...");

    [self _moveNativeExpressAd:x y:y];
}

- (void)_moveNativeExpressAd:(NSNumber* _Nonnull)x y:(NSNumber* _Nonnull)y {
    if ([self _hasNativeExpressAd]) {
        [self _moveAd:[self nativeExpressAdView] x:x y:y];
    }
}

- (BOOL)_hasNativeExpressAd {
    return [self nativeExpressAdView] != nil;
}

- (void)_moveAd:(UIView* _Nonnull)view position:(NSNumber* _Nonnull)_position {
    CGSize rootSize = [AdsWrapper getOrientationDependentScreenSize];

    using namespace cocos2d::plugin;
    ProtocolAds::AdsPos position = (ProtocolAds::AdsPos)([_position intValue]);

    CGSize viewSize = [view frame].size;
    CGPoint viewOrigin;
    switch (position) {
    case ProtocolAds::AdsPos::kPosTop:
        viewOrigin.x = (rootSize.width - viewSize.width) / 2;
        viewOrigin.y = 0.0f;
        break;
    case ProtocolAds::AdsPos::kPosTopLeft:
        viewOrigin.x = 0.0f;
        viewOrigin.y = 0.0f;
        break;
    case ProtocolAds::AdsPos::kPosTopRight:
        viewOrigin.x = rootSize.width - viewSize.width;
        viewOrigin.y = 0.0f;
        break;
    case ProtocolAds::AdsPos::kPosBottom:
        viewOrigin.x = (rootSize.width - viewSize.width) / 2;
        viewOrigin.y = rootSize.height - viewSize.height;
        break;
    case ProtocolAds::AdsPos::kPosBottomLeft:
        viewOrigin.x = 0.0f;
        viewOrigin.y = rootSize.height - viewSize.height;
        break;
    case ProtocolAds::AdsPos::kPosBottomRight:
        viewOrigin.x = rootSize.width - viewSize.width;
        viewOrigin.y = rootSize.height - viewSize.height;
        break;
    case ProtocolAds::AdsPos::kPosCenter:
    default:
        viewOrigin.x = (rootSize.width - viewSize.width) / 2;
        viewOrigin.y = (rootSize.height - viewSize.height) / 2;
        break;
    }

    CGFloat scale = [[UIScreen mainScreen] scale];
    [self _moveAd:view x:@(viewOrigin.x * scale) y:@(viewOrigin.y * scale)];
}

- (void)_moveAd:(UIView* _Nonnull)view
              x:(NSNumber* _Nonnull)x
              y:(NSNumber* _Nonnull)y {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect frame = [view frame];
    frame.origin.x = [x floatValue] / scale;
    frame.origin.y = [y floatValue] / scale;
    [view setFrame:frame];
}

#pragma mark - Interstitial ad

- (void)showInterstitialAd {
    NSLog(@"Interstitial view: %@", [self interstitialAdView]);

    if ([self hasInterstitialAd]) {
        UIViewController* controller =
            [AdsWrapper getCurrentRootViewController];
        [[self interstitialAdView] presentFromRootViewController:controller];
        [AdsWrapper onAdsResult:self
                        withRet:cocos2d::plugin::AdsResultCode::kAdsShown
                        withMsg:@"Ads is shown!"];
    } else {
        // Ad is not ready to present.
        NSLog(@"ADMOB: Interstitial cannot show. It is not ready.");
        // Attempt to load the default interstitial ad id.
        // Should be deprecated: load interstitial should be called manually.
        [self loadInterstitial];
    }
}

- (void)loadInterstitial {
    [self loadInterstitialAd:[self strInterstitialID]];
}

- (void)loadInterstitialAd:(NSString* _Nonnull)adId {
    [self _removeInterstitialAd];

    GADInterstitial* view = [[GADInterstitial alloc] initWithAdUnitID:adId];
    [view setDelegate:self];

    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];
    if ([SSAdColonyMediation isLinkedWithAdColony] &&
        [[self adColonyInterstitialAdZoneId] length] > 0) {
        id<GADAdNetworkExtras> extras = [SSAdColonyMediation
            extrasWithZoneId:[self adColonyInterstitialAdZoneId]];
        [request registerAdNetworkExtras:extras];
    }
    [view loadRequest:request];

    [self setInterstitialAdView:view];
}

- (BOOL)hasInterstitialAd {
    return [[self interstitialAdView] isReady];
}

- (void)_removeInterstitialAd {
    if ([self interstitialAdView] != nil) {
        [[self interstitialAdView] release];
        [self setInterstitialAdView:nil];
    }
}

#pragma mark - Rewarded video ad

- (void)showRewardedAd {
    if ([self hasRewardedAd]) {
        [[GADRewardBasedVideoAd sharedInstance]
            presentFromRootViewController:
                [AdsWrapper getCurrentRootViewController]];
    }
}

- (void)loadRewardedAd:(NSString* _Nonnull)adId {
    [[GADRewardBasedVideoAd sharedInstance] setDelegate:self];

    GADRequest* request = [GADRequest request];
    if ([SSAdColonyMediation isLinkedWithAdColony] &&
        [[self adColonyRewardedAdZoneId] length] > 0) {
        id<GADAdNetworkExtras> extras = [SSAdColonyMediation
            extrasWithZoneId:[self adColonyRewardedAdZoneId]];
        [request registerAdNetworkExtras:extras];
    }

    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:adId];
}

- (BOOL)hasRewardedAd {
    return [[GADRewardBasedVideoAd sharedInstance] isReady];
}

#pragma mark - Utility

- (NSNumber*)getBannerWidthInPixels {
    if (not[self _hasBannerAd]) {
        return @(0);
    }
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.width * scale);
}

- (NSNumber*)getBannerHeightInPixels {
    if (not[self _hasBannerAd]) {
        return @(0);
    }
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.height * scale);
}

- (NSNumber* _Nonnull)getSizeInPixels:(NSNumber* _Nonnull)size_ {
    int size = [size_ intValue];
    if (size == -2) {
        return [self _getAutoHeightInPixels];
    }
    if (size == -1) {
        return [self _getFullWidthInPixels];
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

- (GADAdSize)_createAdSize:(NSNumber* _Nonnull)width
                    height:(NSNumber* _Nonnull)height {
    UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];
    if ([width intValue] == -1) {
        // Full width.
        if ([height intValue] == -2) {
            // Auto height.
            // Smart banner.
            return [self _getSmartBannerAdSize];
        }
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return GADAdSizeFullWidthLandscapeWithHeight([height intValue]);
        }
        return GADAdSizeFullWidthPortraitWithHeight([height intValue]);
    }
    return GADAdSizeFromCGSize(CGSizeMake([width intValue], [height intValue]));
}

- (GADBannerView* _Nullable)_createDummySmartBanner {
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self _getSmartBannerAdSize]];
    return [banner autorelease];
}

- (NSNumber* _Nonnull)_getAutoHeightInPixels {
    GADBannerView* banner = [self _createDummySmartBanner];
    if (banner == nil) {
        NSAssert(NO, @"...");
        return @(0);
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.height * scale);
}

- (NSNumber* _Nonnull)_getFullWidthInPixels {
    GADBannerView* banner = [self _createDummySmartBanner];
    if (banner == nil) {
        NSAssert(NO, @"...");
        return @(0);
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    return @([banner frame].size.width * scale);
}

/// Retrieves the size of the smart banner depends on the orientation of the
/// design resolution.
- (GADAdSize)_getSmartBannerAdSize {
    UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];

    return UIInterfaceOrientationIsLandscape(orientation)
               ? kGADAdSizeSmartBannerLandscape
               : kGADAdSizeSmartBannerPortrait;
}

#pragma mark GADBannerViewDelegate impl

// Since we've received an ad, let's go ahead and set the frame to display it.
- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    NSLog(@"Received ad");
    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kAdsBannerReceived
                    withMsg:@"Ads request received success!"];
}

- (void)adView:(GADBannerView*)view
    didFailToReceiveAdWithError:(GADRequestError*)error {
    NSLog(@"Failed to receive ad with error: %@",
          [error localizedFailureReason]);
    auto errorNo = cocos2d::plugin::AdsResultCode::kAdsUnknownError;
    switch ([error code]) {
    case kGADErrorNetworkError:
        errorNo = cocos2d::plugin::AdsResultCode::kNetworkError;
        break;
    default:
        break;
    }
    [AdsWrapper onAdsResult:self
                    withRet:errorNo
                    withMsg:[error localizedDescription]];
}

#pragma mark GADInterstitialDelegate impl

- (void)interstitialDidReceiveAd:(GADInterstitial*)ad {
    OUTPUT_LOG(@"Interstitial ad was loaded. Can present now.");
    [AdsWrapper
        onAdsResult:self
            withRet:cocos2d::plugin::AdsResultCode::kAdsInterstitialReceived
            withMsg:@"Ads request received success!"];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial*)ad
    didFailToReceiveAdWithError:(GADRequestError*)error {
    OUTPUT_LOG(@"Interstitial failed to load with error: %@",
               [error description]);

    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kAdsUnknownError
                    withMsg:[error description]];
}

#pragma mark Display-Time Lifecycle Notifications

- (void)interstitialWillPresentScreen:(GADInterstitial*)ad {
    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kAdsShown
                    withMsg:@"Interstitial is showing"];
}

- (void)interstitialWillDismissScreen:(GADInterstitial*)ad {
    OUTPUT_LOG(@"Interstitial will dismiss.");
}

- (void)interstitialDidDismissScreen:(GADInterstitial*)ad {
    OUTPUT_LOG(@"Interstitial dismissed")
        [AdsWrapper onAdsResult:self
                        withRet:cocos2d::plugin::AdsResultCode::kAdsDismissed
                        withMsg:@"Interstital dismissed."];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial*)ad {
    OUTPUT_LOG(@"Interstitial will leave application.");
}

#pragma mark - Rewarded Video Ad Delegate

- (void)rewardBasedVideoAdDidReceiveAd:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is received.");
    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kVideoReceived
                    withMsg:@"Reward based video ad is received."];
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"Opened reward based video ad.");
    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kVideoShown
                    withMsg:@"Opened reward based video ad."];
}

- (void)rewardBasedVideoAdDidStartPlaying:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"Reward based video ad is closed.");
    [AdsWrapper onAdsResult:self
                    withRet:cocos2d::plugin::AdsResultCode::kVideoClosed
                    withMsg:@"Reward based video ad is closed."];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd*)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward*)reward {
    NSString* rewardMessage = [NSString
        stringWithFormat:@"Reward received with currency %@ , amount %@",
                         [reward type], [reward amount]];
    NSLog(@"%@", rewardMessage);
    // Reward the user for watching the video.
}

- (void)rewardBasedVideoAdWillLeaveApplication:
        (GADRewardBasedVideoAd*)rewardBasedVideoAd {
    NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd*)rewardBasedVideoAd
    didFailToLoadWithError:(NSError*)error {
    NSLog(@"Reward based video ad failed to load.");
    [AdsWrapper
        onAdsResult:self
            withRet:cocos2d::plugin::AdsResultCode::kVideoUnknownError
            withMsg:[NSString stringWithFormat:@"Reward based video ad failed "
                                               @"to load with error: %@",
                                               error]];
}

@end
