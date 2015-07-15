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


- (void) dispatchHits
{
    [[GAI sharedInstance] dispatch];
}
- (void) dispatchPeriodically: (int) seconds
{
    [GAI sharedInstance].dispatchInterval = seconds;
}

- (void) stopPeriodicalDispatch
{
    // Disable periodic dispatch by setting dispatch interval to a value less than 1.
    [GAI sharedInstance].dispatchInterval = 0;
}

- (void) logScreen:(NSString *)screenName
{
    if (self.tracker) {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    } else {
        OUTPUT_LOG(@"Log Screen called w/o valid tracker");
    }
}

- (void) logEventWithCategory:(NSString *)category action: (NSString*) action label: (NSString*) label value: (NSNumber*) value
{
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
    } else {
        OUTPUT_LOG(@"Log Event called w/o valid tracker");
    }
}

- (void) logExceptionWithDescription: (NSString*) description fatal: (BOOL) isFatal {
    
    if (self.tracker) {
        
        [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:description withFatal:isFatal ? @YES : @NO] build]];
    } else {
        OUTPUT_LOG(@"Log Exception called w/o valid tracker.");
    }
}

- (void) logTimmingWithCategory: (NSString*) category interval: (int) interval name:(NSString*) name label: (NSString*) label
{
    
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:[NSNumber numberWithInt:interval] name:name label:label] build]];
    } else {
        OUTPUT_LOG(@"Timing called w/o valid tracker");
    }
}

- (void) logSocialWithNetwork: (NSString*) network action: (NSString*) action target: (NSString*) target
{
    if (self.tracker) {
        [self.tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:network action:action target:target] build]];
    } else {
        OUTPUT_LOG(@"Log Social called w/o valid tracker.");
    }
}

- (void) setDryRun: (BOOL) isDryRun
{
    [self setDebugMode:isDryRun];
}

- (void) enableAdvertisingTracking: (BOOL) enable
{
    if (self.tracker) {
        [self.tracker setAllowIDFACollection: enable];
    }
    else {
        OUTPUT_LOG(@"Advertising called w/o valid tracker.");
    }
}

@end