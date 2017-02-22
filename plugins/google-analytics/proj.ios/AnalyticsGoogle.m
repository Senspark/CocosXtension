//
//  AnalyticsGoogle.cpp
//  PluginGoogleAnalytics
//
//  Created by Duc Nguyen on 7/7/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import "AnalyticsGoogle.h"
#import "GAILogger.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAILogger.h"
#import "GAIFields.h"
#import "GAIEcommerceFields.h"

#define OUTPUT_LOG(...)                                                        \
    if (_debug)                                                                \
        NSLog(__VA_ARGS__);

@implementation AnalyticsGoogle

#pragma mark - Analytics Interface

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    [self setRegisteredTrackers:[NSMutableDictionary dictionary]];
    return self;
}

- (void)dealloc {
    [self setRegisteredTrackers:nil];
}

- (void)startSession:(NSString*)appKey {
    if ([self currentTracker] != nil) {
        // Start a new session with a screenView hit.
        GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
        [builder set:@"start" forKey:kGAISessionControl];
        [[self currentTracker] set:kGAIScreenName value:appKey];
        [[self currentTracker] send:[builder build]];
    } else {
        OUTPUT_LOG(@"Start session called w/o valid tracker.");
    }
}

- (void)stopSession {
    if ([self currentTracker] != nil) {
        GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
        [builder set:@"end" forKey:kGAISessionControl];
        [[self currentTracker] send:[builder build]];
    } else {
        OUTPUT_LOG(@"Stop session called w/o valid tracker.");
    }
}

- (void)setSessionContinueMillis:(long)millis {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void)setCaptureUncaughtException:(BOOL)isEnabled {
    [[GAI sharedInstance] setTrackUncaughtExceptions:isEnabled];
}

- (void)setDebugMode:(BOOL)isDebugMode {
    _debug = isDebugMode;
    [[GAI sharedInstance] setDryRun:isDebugMode];
}

- (void)logError:(NSString*)errorId withMsg:(NSString*)message {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void)logEvent:(NSString*)eventId {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void)logEvent:(NSString*)eventId withParam:(NSMutableDictionary*)paramMap {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void)logTimedEventBegin:(NSString*)eventId {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void)logTimedEventEnd:(NSString*)eventId {
    OUTPUT_LOG(@"Not supported on iOS");
}

- (NSString*)getSDKVersion {
    return @"3.12";
}

- (NSString*)getPluginVersion {
    return @"0.1.0";
}

#pragma mark - Google Analytics Interface

- (void)configureTracker:(NSString*)trackerId {
    if (nil == trackerId) {
        OUTPUT_LOG(@"Null tracker id at configure time.");
        return;
    }

    OUTPUT_LOG(@"Configure with trackerId: %@", trackerId);
    [self createTracker:trackerId];
}

- (id<GAITracker>)_getTrackerWithId:(NSString*)trackerId {
    return [[self registeredTrackers] objectForKey:trackerId];
}

- (void)_registerTracker:(id<GAITracker>)tracker withId:(NSString*)trackerId {
    [[self registeredTrackers] setValue:tracker forKey:trackerId];
}

- (void)_enableTracker:(id<GAITracker>)tracker {
    [self setCurrentTracker:tracker];
}

- (void)enableTracker:(NSString*)trackerId {
    if (nil == trackerId) {
        return;
    }

    id<GAITracker> tracker = [self _getTrackerWithId:trackerId];
    if (tracker == nil) {
        OUTPUT_LOG(@"Trying to enable unknown tracker: %@", trackerId);
    } else {
        OUTPUT_LOG(@"Selected tracker: %@", trackerId);
        [self _enableTracker:tracker];
    }
}

- (void)createTracker:(NSString*)trackerId {
    id<GAITracker> tracker = [self _getTrackerWithId:trackerId];
    if (tracker == nil) {
        tracker = [[GAI sharedInstance] trackerWithTrackingId:trackerId];
        [self _registerTracker:tracker withId:trackerId];
    }

    [self _enableTracker:tracker];
}

- (void)setLogLevel:(NSNumber*)logLevel {
    [[[GAI sharedInstance] logger] setLogLevel:[logLevel unsignedIntegerValue]];
}

- (void)dispatchHits {
    [[GAI sharedInstance] dispatch];
}

- (void)dispatchPeriodically:(NSNumber*)seconds {
    [[GAI sharedInstance] setDispatchInterval:[seconds intValue]];
}

- (void)stopPeriodicalDispatch {
    // Disable periodic dispatch by setting dispatch interval to a value less
    // than 1.
    [[GAI sharedInstance] setDispatchInterval:0];
}

- (void)_setParameter:(NSString*)key value:(NSString*)value {
    id<GAITracker> tracker = [self currentTracker];
    if (tracker != nil) {
        [tracker set:key value:value];
    } else {
        OUTPUT_LOG(@"Set parameter called w/o valid tracker");
    }
}

- (void)setParameter:(NSDictionary*)dict {
    NSString* param1 = [dict objectForKey:@"Param1"];
    NSString* param2 = [dict objectForKey:@"Param2"];
    [self _setParameter:param1 value:param2];
}

- (void)sendHit:(NSDictionary*)dict {
    id<GAITracker> tracker = [self currentTracker];
    if (tracker != nil) {
        [tracker send:dict];
    } else {
        OUTPUT_LOG(@"Send hit called w/o valid tracker");
    }
}

- (void)setDryRun:(NSNumber*)isDryRun {
    [self setDebugMode:[isDryRun boolValue]];
}

- (void)enableAdvertisingTracking:(NSNumber*)enabled {
    id<GAITracker> tracker = [self currentTracker];
    if (tracker != nil) {
        [tracker setAllowIDFACollection:[enabled boolValue]];
    } else {
        OUTPUT_LOG(@"Advertising called w/o valid tracker.");
    }
}

- (void)_checkDictionary:(NSDictionary*)builtDict
                    dict:(NSDictionary*)expectedDict {
    if ([builtDict isEqualToDictionary:expectedDict]) {
        // Ok.
    } else {
        NSLog(@"Dictionary unmatched: %@ vs %@", builtDict, expectedDict);
        NSAssert(NO, @"..");
    }
}

- (void)_testTrackScreenView:(NSDictionary*)dict {
    NSDictionary* expectedDict =
        [[GAIDictionaryBuilder createScreenView] build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testTrackEvent:(NSDictionary*)dict {
    NSDictionary* expectedDict =
        [[GAIDictionaryBuilder createEventWithCategory:@"category"
                                                action:@"action"
                                                 label:@"label"
                                                 value:@(1)] build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testTrackTiming:(NSDictionary*)dict {
    NSDictionary* expectedDict =
        [[GAIDictionaryBuilder createTimingWithCategory:@"category"
                                               interval:@(1)
                                                   name:@"variable"
                                                  label:@"label"] build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testTrackException:(NSDictionary*)dict {
    NSDictionary* expectedDict =
        [[GAIDictionaryBuilder createExceptionWithDescription:@"description"
                                                    withFatal:@(YES)] build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testTrackSocial:(NSDictionary*)dict {
    NSDictionary* expectedDict =
        [[GAIDictionaryBuilder createSocialWithNetwork:@"network"
                                                action:@"action"
                                                target:@"target"] build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testCustomDimensionAndMetric:(NSDictionary*)dict {
    GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
    [builder set:@"1" forKey:[GAIFields customMetricForIndex:1]];
    [builder set:@"2" forKey:[GAIFields customMetricForIndex:2]];
    [builder set:@"5.5" forKey:[GAIFields customMetricForIndex:5]];
    [builder set:@"dimension_1" forKey:[GAIFields customDimensionForIndex:1]];
    [builder set:@"dimension_2" forKey:[GAIFields customDimensionForIndex:2]];

    NSDictionary* expectedDict = [builder build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testEcommerceImpression:(NSDictionary*)dict {
    GAIEcommerceProduct* product0 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product0 setCategory:@"category0"];
    [product0 setId:@"id0"];
    [product0 setName:@"name0"];
    [product0 setPrice:@(1.5)];

    GAIEcommerceProduct* product1 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product1 setCategory:@"category1"];
    [product1 setId:@"id1"];
    [product1 setName:@"name1"];
    [product1 setPrice:@(2.5)];

    GAIEcommerceProduct* product2 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product2 setCategory:@"category2"];
    [product2 setId:@"id2"];
    [product2 setName:@"name2"];
    [product2 setPrice:@(3.0)];

    GAIEcommerceProduct* product3 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product3 setCategory:@"category3"];
    [product3 setId:@"id3"];
    [product3 setName:@"name3"];
    [product3 setPrice:@(4)];

    GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
    [builder addProductImpression:product0
                   impressionList:@"impressionList0"
                 impressionSource:nil];
    [builder addProductImpression:product1
                   impressionList:@"impressionList0"
                 impressionSource:nil];
    [builder addProductImpression:product2
                   impressionList:@"impressionList1"
                 impressionSource:nil];
    [builder addProductImpression:product3
                   impressionList:@"impressionList1"
                 impressionSource:nil];

    NSDictionary* expectedDict = [builder build];
    [self _checkDictionary:dict dict:expectedDict];
}

- (void)_testEcommerceAction:(NSDictionary*)dict {
    GAIEcommerceProduct* product0 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product0 setCategory:@"category0"];
    [product0 setId:@"id0"];
    [product0 setName:@"name0"];
    [product0 setPrice:@(1.5)];

    GAIEcommerceProduct* product1 =
        [[[GAIEcommerceProduct alloc] init] autorelease];
    [product1 setCategory:@"category1"];
    [product1 setId:@"id1"];
    [product1 setName:@"name1"];
    [product1 setPrice:@(2)];

    GAIEcommerceProductAction* action =
        [[[GAIEcommerceProductAction alloc] init] autorelease];
    [action setAction:kGAIPAPurchase];
    [action setProductActionList:@"actionList"];
    [action setProductListSource:@"listSource"];
    [action setTransactionId:@"transactionId"];
    [action setRevenue:@(2.0)];

    GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
    [builder addProduct:product0];
    [builder addProduct:product1];
    [builder setProductAction:action];

    NSDictionary* expectedDict = [builder build];
    [self _checkDictionary:dict dict:expectedDict];
}

@end
