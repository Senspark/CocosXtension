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

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation AnalyticsGoogle

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

- (void) logScreen:(NSString *)screenName
{
    if (self.tracker) {
        [self.tracker set:kGAIScreenName value:screenName];
        [self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    } else {
        OUTPUT_LOG(@"Log Screen called w/o valid tracker");
    }
}

- (void) setSessionContinueMillis: (long) millis
{
    
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
    
}

- (void) logEvent: (NSString*) eventId
{
    OUTPUT_LOG(@"Log Event w/o parameters is not support in Google Analytics.");
}

- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap
{
    if (self.tracker) {
        NSString* eventCategory = [[paramMap objectForKey:kGAIEventCategory] stringValue];
        NSString* eventAction = [[paramMap objectForKey:kGAIEventAction] stringValue];
        NSString* eventLabel = [[paramMap objectForKey:kGAIEventLabel] stringValue];
        NSNumber* eventValue = [paramMap objectForKey:kGAIEventValue];
        
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventCategory action:eventAction label:eventLabel value:eventValue] build]];
    } else {
        OUTPUT_LOG(@"Log Event called w/o valid tracker");
    }
}

- (void) logTimedEventBegin: (NSString*) eventId
{
    
}

- (void) logTimedEventEnd: (NSString*) eventId
{
    
}

- (NSString*) getSDKVersion
{
    return @"3.12";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

@end