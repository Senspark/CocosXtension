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

    adViews_ = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc {
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

    for (NSString* key in [adViews_ allKeys]) {
        [self destroyAd:key];
    }
    [adViews_ release];
    adViews_ = nil;

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
}

- (void)hideAds:(NSDictionary*)info {
    NSLog(@"Deprecated: Use hideBannerAd(adId) instead!");

    NSString* strType = [info objectForKey:@"AdmobType"];
    int type = [strType intValue];
    switch (type) {
    case kTypeBanner: {
        [self hideAd:[self strBannerID]];
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

#pragma mark - Banner ad & native express ad

- (void)createBannerAd:(NSDictionary*)params {
    NSAssert([params count] == 3, @"Invalid number of params");

    NSString* adId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");

    [self _createAd:SSAdMobAdTypeBanner adId:adId width:width height:height];
}

- (void)createNativeExpressAd:(NSDictionary* _Nonnull)params {
    NSAssert([params count] == 3, @"Invalid number of params");

    NSString* adId = params[@"Param1"];
    NSNumber* width = params[@"Param2"];
    NSNumber* height = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([width isKindOfClass:[NSNumber class]], @"...");
    NSAssert([height isKindOfClass:[NSNumber class]], @"...");

    [self _createAd:SSAdMobAdTypeNativeExpress
               adId:adId
              width:width
             height:height];
}

- (void)_createAd:(SSAdMobAdType)adType
             adId:(NSString* _Nonnull)adId
            width:(NSNumber* _Nonnull)width
           height:(NSNumber* _Nonnull)height {
    GADAdSize size = [self _createAdSize:width height:height];
    if ([self _hasAd:adId size:size]) {
        NSLog(@"%s: attempted to create an ad with id = %@ width = %@ height = "
              @"%@ but it is already created.",
              __PRETTY_FUNCTION__, adId, width, height);
        return;
    }

    [self _createAd:adType adId:adId size:size];
}

- (BOOL)_hasAd:(NSString* _Nonnull)adId size:(GADAdSize)size {
    NSValue* elt = [adSizes_ objectForKey:adId];
    if (elt == nil) {
        return NO;
    }

    GADAdSize cachedSize = GADAdSizeFromNSValue(elt);
    if (CGSizeEqualToSize(size.size, cachedSize.size) &&
        size.flags == cachedSize.flags) {
        return YES;
    }
    return NO;
}

- (void)_createAd:(SSAdMobAdType)adType
             adId:(NSString* _Nonnull)adId
             size:(GADAdSize)size {
    [self destroyAd:adId];

    UIView* _view = nil;
    UIViewController* controller =
        [SSAdMobUtility getCurrentRootViewController];
    GADRequest* request = [GADRequest request];
    [request setTestDevices:[self testDeviceIDs]];

    if (adType == SSAdMobAdTypeBanner) {
        GADBannerView* view =
            [[[GADBannerView alloc] initWithAdSize:size] autorelease];
        if (view == nil) {
            NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
            return;
        }

        [view setAdUnitID:adId];
        [view setDelegate:bannerAdListener_];
        [view setRootViewController:controller];
        [view loadRequest:request];
    } else if (adType == SSAdMobAdTypeNativeExpress) {
        GADNativeExpressAdView* view =
            [[[GADNativeExpressAdView alloc] initWithAdSize:size] autorelease];
        if (view == nil) {
            NSLog(@"%s: invalid ad size.", __PRETTY_FUNCTION__);
            return;
        }

        [view setAdUnitID:adId];
        [view setDelegate:nativeExpressAdListener_];
        [view setRootViewController:controller];
        [view loadRequest:request];
    } else {
        NSAssert(NO, @"...");
    }

    [_view setHidden:YES];
    [[controller view] addSubview:_view];

    [adViews_ setObject:_view forKey:adId];
    [adSizes_ setObject:NSValueFromGADAdSize(size) forKey:adId];
}

- (void)destroyAd:(NSString* _Nonnull)adId {
    UIView* view = [adViews_ objectForKey:adId];
    if (view == nil) {
        NSLog(@"%s: attempted to destroy a non-created ad with id = %@",
              __PRETTY_FUNCTION__, adId);
        return;
    }

    [view removeFromSuperview];
    [adViews_ removeObjectForKey:adId];
}

- (void)showAd:(NSString* _Nonnull)adId {
    UIView* view = [adViews_ objectForKey:adId];
    if (view == nil) {
        NSLog(@"%s: attempted to show a non-created ad with id = %@",
              __PRETTY_FUNCTION__, adId);
        return;
    }

    [view setHidden:NO];
}

- (void)hideAd:(NSString* _Nonnull)adId {
    UIView* view = [adViews_ objectForKey:adId];
    if (view == nil) {
        NSLog(@"%s: attempted to hide a non-created ad with id = %@",
              __PRETTY_FUNCTION__, adId);
        return;
    }

    [view setHidden:YES];
}

- (void)moveAd:(NSDictionary* _Nonnull)params {
    NSAssert([params count] == 3, @"...");

    NSString* adId = params[@"Param1"];
    NSNumber* x = params[@"Param2"];
    NSNumber* y = params[@"Param3"];

    NSAssert([adId isKindOfClass:[NSString class]], @"...");
    NSAssert([x isKindOfClass:[NSNumber class]], @"...");
    NSAssert([y isKindOfClass:[NSNumber class]], @"...");

    [self _moveAd:adId x:x y:y];
}

- (void)_moveAd:(NSString* _Nonnull)adId
              x:(NSNumber* _Nonnull)x
              y:(NSNumber* _Nonnull)y {
    UIView* view = [adViews_ objectForKey:adId];
    if (view == nil) {
        NSLog(@"%s: attempted to move a non-created ad with id = %@",
              __PRETTY_FUNCTION__, adId);
        return;
    }

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
