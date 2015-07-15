//
//  AnalyticsGoogle.h
//  PluginGoogleAnalytics
//
//  Created by Duc Nguyen on 7/7/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef __PluginGoogleAnalytics__AnalyticsGoogle__
#define __PluginGoogleAnalytics__AnalyticsGoogle__

#import "InterfaceAnalytics.h"
#import "GAITracker.h"

@interface AnalyticsGoogle : NSObject <InterfaceAnalytics>
{
}

@property (nonatomic, assign) NSDictionary *trackers;
@property (nonatomic, assign) id<GAITracker> tracker;
@property BOOL debug;

/**
 interfaces of protocol : InterfaceAnalytics
 */
- (void) startSession: (NSString*) appKey;
- (void) stopSession;
- (void) setSessionContinueMillis: (long) millis;
- (void) setCaptureUncaughtException: (BOOL) isEnabled;
- (void) setDebugMode: (BOOL) isDebugMode;
- (void) logError: (NSString*) errorId withMsg:(NSString*) message;
- (void) logEvent: (NSString*) eventId;
- (void) logEvent: (NSString*) eventId withParam:(NSMutableDictionary*) paramMap;
- (void) logTimedEventBegin: (NSString*) eventId;
- (void) logTimedEventEnd: (NSString*) eventId;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;


/**
 interfaces of Google Analytics SDK
 */
- (void) logScreen: (NSString*) screenName;

#endif /* defined(__PluginGoogleAnalytics__AnalyticsGoogle__) */
