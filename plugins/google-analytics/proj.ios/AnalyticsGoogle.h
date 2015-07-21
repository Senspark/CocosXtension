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
    BOOL _debug;
}

@property (nonatomic, retain) NSDictionary *trackers;
@property (nonatomic, retain) id<GAITracker> tracker;

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

- (void) configureTracker: (NSString*) trackerId;
- (void) enableTracker: (NSString*) trackerId;
- (void) createTracker: (NSString*) trackerId;

- (void) dispatchHits;
- (void) dispatchPeriodically: (int) seconds;
- (void) stopPeriodicalDispatch;

- (void) logScreen: (NSString*) screenName;
- (void) logEventWithCategory:(NSString *)category action: (NSString*) action label: (NSString*) label value: (NSNumber*) value;
- (void) logExceptionWithDescription: (NSString*) description fatal: (BOOL) isFatal;
- (void) logTimmingWithCategory: (NSString*) category interval: (int) interval name:(NSString*) name label: (NSString*) label;
- (void) logSocialWithNetwork: (NSString*) network action: (NSString*) action target: (NSString*) target;
- (void) setDryRun: (BOOL) isDryRun;
- (void) enableAdvertisingTracking: (BOOL) enable;

@end
#endif /* defined(__PluginGoogleAnalytics__AnalyticsGoogle__) */
