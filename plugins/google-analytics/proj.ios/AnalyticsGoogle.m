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

#define OUTPUT_LOG(...)     if (_debug) NSLog(__VA_ARGS__);

@implementation AnalyticsGoogle


#pragma mark - Analytics Interface

- (id) init
{
    self = [super init];
    if (self) {
        self.trackers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void) startSession: (NSString*) appKey
{
    if (self.tracker) {
        // Start a new session with a screenView hit.
        GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
        [builder set:@"start" forKey:kGAISessionControl];
        [self.tracker set:kGAIScreenName value:appKey];
        [self.tracker send:[builder build]];
    } else {
        OUTPUT_LOG(@"Start session called w/o valid tracker.");
    }
}

- (void) stopSession
{
    if (self.tracker) {
        GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
        [builder set:@"end" forKey:kGAISessionControl];
        [self.tracker send:[builder build]];
    } else {
        OUTPUT_LOG(@"Stop session called w/o valid tracker.");
    }
}

- (void) setSessionContinueMillis: (long) millis
{
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void) setCaptureUncaughtException: (BOOL) isEnabled
{
    [[GAI sharedInstance] setTrackUncaughtExceptions:isEnabled];
}

- (void) setDebugMode: (BOOL) isDebugMode
{
    _debug = isDebugMode;
    [[GAI sharedInstance] setDryRun:isDebugMode];
}

- (void) logError: (NSString*) errorId withMsg:(NSString*) message
{
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void) logTimedEventBegin: (NSString*) eventId
{
    OUTPUT_LOG(@"Not supported on iOS");
}

- (void) logTimedEventEnd: (NSString*) eventId
{
    OUTPUT_LOG(@"Not supported on iOS");
}


- (NSString*) getSDKVersion
{
    return @"3.12";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

#pragma mark - Google Analytics Interface

- (void) configureTracker: (NSString*) trackerId
{
    if (nil == trackerId) {
        OUTPUT_LOG(@"Null tracker id at configure time.");
        return;
    }
    
    OUTPUT_LOG(@"Configure with trackerId: %@", trackerId);
    
    [self createTracker:trackerId];
}

- (void) enableTracker: (NSString*) trackerId
{
    if (nil == trackerId) {
        return;
    }
    
    id<GAITracker> tr = [self.trackers objectForKey:trackerId];
    if (tr == nil) {
        OUTPUT_LOG(@"Trying to enable unknown tracker: %@", trackerId);
    } else {
        OUTPUT_LOG(@"Selected tracker: %@", trackerId);
        self.tracker = tr;
    }
}

- (void) createTracker: (NSString*) trackerId
{
    id<GAITracker> tr = [self.trackers objectForKey:trackerId];
    
    if (tr == nil) {
        tr = [[GAI sharedInstance] trackerWithTrackingId:trackerId];
        [self.trackers setValue:tr forKey:trackerId];
    }
    
    [self enableTracker:trackerId];
}

- (void) setLogLevel: (NSNumber*) logLevel
{
    [[[GAI sharedInstance] logger] setLogLevel:[logLevel unsignedIntegerValue]];
}

- (void) dispatchHits
{
    [[GAI sharedInstance] dispatch];
}

- (void) dispatchPeriodically: (NSNumber*) seconds
{
    [GAI sharedInstance].dispatchInterval = [seconds intValue];
}

- (void) stopPeriodicalDispatch
{
    // Disable periodic dispatch by setting dispatch interval to a value less than 1.
    [GAI sharedInstance].dispatchInterval = 0;
}

- (void) trackScreen:(NSString *)screenName
{
    if (self.tracker) {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    } else {
        OUTPUT_LOG(@"Log Screen called w/o valid tracker");
    }
}

- (void) trackEventWithCategory:(NSString *)category action: (NSString*) action label: (NSString*) label value: (NSNumber*) value
{
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
    } else {
        OUTPUT_LOG(@"Log Event called w/o valid tracker");
    }
}

- (void) trackEventWithCategory: (NSMutableDictionary*) params {
    NSString* category = (NSString*) [params objectForKey:@"Param1"];
    NSString* action = (NSString*) [params objectForKey:@"Param2"];
    NSString* label = (NSString*) [params objectForKey:@"Param3"];
    NSNumber* value = (NSNumber*) [params objectForKey:@"Param4"];
    
    [self trackEventWithCategory:category action:action label:label value:value];
}

- (void) trackExceptionWithDescription: (NSString*) description fatal: (BOOL) isFatal {
    
    if (self.tracker) {
        
        [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:description withFatal:isFatal ? @YES : @NO] build]];
    } else {
        OUTPUT_LOG(@"Log Exception called w/o valid tracker.");
    }
}

- (void) trackExceptionWithDescription: (NSMutableDictionary*) params
{
    NSString* description = (NSString*) [params objectForKey:@"Param1"];
    BOOL isFatal = [(NSNumber*) [params objectForKey:@"Param2"] boolValue];
    
    [self trackExceptionWithDescription:description fatal:isFatal];
}

- (void) trackTimmingWithCategory: (NSString*) category interval: (int) interval name:(NSString*) name label: (NSString*) label
{
    
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:[NSNumber numberWithInt:interval] name:name label:label] build]];
    } else {
        OUTPUT_LOG(@"Timing called w/o valid tracker");
    }
}

- (void) trackTimmingWithCategory: (NSMutableDictionary*) params
{
    NSString* category = (NSString*) [params objectForKey:@"Param1"];
    int interval = [(NSNumber*) [params objectForKey:@"Param2"] intValue];
    NSString* name = (NSString*) [params objectForKey:@"Param3"];
    NSString* label = (NSString*) [params objectForKey:@"Param4"];
    
    [self trackTimmingWithCategory:category interval:interval name:name label:label];
}

- (void) trackSocialWithNetwork: (NSString*) network action: (NSString*) action target: (NSString*) target
{
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:network action:action target:target] build]];
    } else {
        OUTPUT_LOG(@"Log Social called w/o valid tracker.");
    }
}

- (void) trackSocialWithNetwork: (NSMutableDictionary*) params
{
    NSString* network = (NSString*) [params objectForKey:@"Param1"];
    NSString* action = (NSString*) [params objectForKey:@"Param2"];
    NSString* target = (NSString*) [params objectForKey:@"Param3"];

    [self trackSocialWithNetwork:network action:action target:target];
}

- (void) setDryRun: (NSNumber*) isDryRun
{
    [self setDebugMode:[isDryRun boolValue]];
}

- (void) enableAdvertisingTracking: (NSNumber*) enable
{
    if (self.tracker) {
        [self.tracker setAllowIDFACollection: [enable boolValue]];
    }
    else {
        OUTPUT_LOG(@"Advertising called w/o valid tracker.");
    }
}

@end