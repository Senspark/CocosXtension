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

- (void)trackEcommerceTransactions:(NSString*)identity
                              name:(NSString*)name
                          category:(NSString*)category
                             price:(NSNumber*)priceValue {
    /*
    if (self.tracker) {
        NSString* productID =
            [NSString stringWithFormat:@"Product-%@", identity];
        NSString* transactionID =
            [NSString stringWithFormat:@"Transaction-%@", identity];

        GAIEcommerceProduct* product = [[GAIEcommerceProduct alloc] init];
        [product setId:productID];
        [product setName:name];
        [product setCategory:category];
        [product setPrice:priceValue];
        GAIDictionaryBuilder* builder =
            [GAIDictionaryBuilder createEventWithCategory:@"Ecommerce"
                                                   action:@"Purchase"
                                                    label:nil
                                                    value:nil];
        GAIEcommerceProductAction* action =
            [[GAIEcommerceProductAction alloc] init];
        [action setAction:kGAIPAPurchase];
        [action setTransactionId:transactionID];
        [action setRevenue:priceValue];
        [builder setProductAction:action];

        // Sets the product for the next available slot, starting with 1
        [builder addProduct:product];
        [self.tracker send:[builder build]];
    }
     */
}

- (void)trackEcommerceTransactions:(NSMutableDictionary*)params {
    NSString* identity = (NSString*)[params objectForKey:@"Param1"];
    NSString* name = (NSString*)[params objectForKey:@"Param2"];
    NSString* category = (NSString*)[params objectForKey:@"Param3"];
    NSNumber* price = (NSNumber*)[params objectForKey:@"Param4"];

    [self trackEcommerceTransactions:identity
                                name:name
                            category:category
                               price:price];
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

@end
