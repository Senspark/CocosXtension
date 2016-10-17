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

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "AdsAdmob.h"
#import "SSBannerAdListener.h"
#import "SSNativeExpressAdListener.h"
#import "SSInterstitialAdListener.h"
#import "SSRewardedVideoAdListener.h"
#import "SSAdColonyMediation.h"
#import "SSAdMobUtility.h"
#import "AdsWrapper.h"

#define OUTPUT_LOG(...)                                                        \
    if (self.debug)                                                            \
        NSLog(__VA_ARGS__);

@implementation AdsAdmob

- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }

    bannerAdListener_ = [[SSBannerAdListener alloc] initWithAdsInterface:self];

    nativeExpressAdListener_ =
        [[SSNativeExpressAdListener alloc] initWithAdsInterface:self];

    interstitialAdListener_ =
        [[SSInterstitialAdListener alloc] initWithAdsInterface:self];

    rewardedVideoAdListener_ =
        [[SSRewardedVideoAdListener alloc] initWithAdsInterface:self];

    return self;
}

- (void)dealloc {
    [self hideBannerAd];
    [self hideNativeExpressAd];
    [self _removeInterstitialAd];
    [self setTestDeviceIDs:nil];

    [bannerAdListener_ release];
    bannerAdListener_ = nil;

    [nativeExpressAdListener_ release];
    nativeExpressAdListener_ = nil;

    [interstitialAdListener_ release];
    interstitialAdListener_ = nil;

    [rewardedVideoAdListener_ release];
    rewardedVideoAdListener_ = nil;

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
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");

    [self _showBannerAd:adId width:width height:height];
}

- (void)_showBannerAd:(NSString* _Nonnull)adId
                width:(NSNumber* _Nonnull)width
               height:(NSNumber* _Nonnull)height {
    [self hideBannerAd];

    GADAdSize size = [self _createAdSize:width height:height];
    [self setBannerAdSize:size];

    GADBannerView* view =
        [[[GADBannerView alloc] initWithAdSize:size] autorelease];
    if (view == nil) {
        NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
        return;
    }

    [view setAdUnitID:adId];
    [view setDelegate:bannerAdListener_];

    UIViewController* controller =
        [SSAdMobUtility getCurrentRootViewController];
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
    NSAssert([params count] == 3, @"Invalid number of params");

    NSString* adUnitId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];

    NSAssert([adUnitId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");

    [self _showNativeExpressAd:adUnitId width:width height:height];
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

    UIViewController* controller =
        [SSAdMobUtility getCurrentRootViewController];
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

- (void)_moveAd:(UIView* _Nonnull)view
              x:(NSNumber* _Nonnull)x
              y:(NSNumber* _Nonnull)y {
    CGFloat scale = [self _getRetinaScale];
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
    [view setDelegate:interstitialAdListener_];

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
    [[GADRewardBasedVideoAd sharedInstance]
        setDelegate:rewardedVideoAdListener_];

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
    if ([self _hasBannerAd] == NO) {
        return @(0);
    }
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [self _getRetinaScale];
    return @([banner frame].size.width * scale);
}

- (NSNumber*)getBannerHeightInPixels {
    if ([self _hasBannerAd] == NO) {
        return @(0);
    }
    GADBannerView* banner =
        [[GADBannerView alloc] initWithAdSize:[self bannerAdSize]];
    if (banner == nil) {
        return @(0);
    }

    CGFloat scale = [self _getRetinaScale];
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
    CGFloat scale = [self _getRetinaScale];
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
    CGFloat scale = [self _getRetinaScale];
    return @([banner frame].size.height * scale);
}

- (NSNumber* _Nonnull)_getFullWidthInPixels {
    GADBannerView* banner = [self _createDummySmartBanner];
    if (banner == nil) {
        NSAssert(NO, @"...");
        return @(0);
    }
    CGFloat scale = [self _getRetinaScale];
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

- (NSNumber* _Nonnull)getRealScreenWidthInPixels {
    return @([self _getRealScreenSizeInPixels].width);
}

- (NSNumber* _Nonnull)getRealScreenHeightInPixels {
    return @([self _getRealScreenSizeInPixels].height);
}

- (CGSize)_getRealScreenSizeInPixels {
    CGSize rootSize = [AdsWrapper getOrientationDependentScreenSize];
    CGFloat scale = [self _getRetinaScale];
    return CGSizeMake(rootSize.width * scale, rootSize.height * scale);
}

- (CGFloat)_getRetinaScale {
    CGFloat scale = [[UIScreen mainScreen] scale];
    return scale;
}

@end
