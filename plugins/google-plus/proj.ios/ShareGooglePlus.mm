//
//  ShareGooglePlus.mm
//  PluginGooglePlay
//
//  Created by Nikel Arteta on 12/2/15.
//  Copyright © 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import "ShareGooglePlus.h"
#import "ShareWrapper.h"
#import "ProtocolShare.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

using namespace cocos2d::plugin;

@interface GPPShareDelegate : NSObject <GPPDeepLinkDelegate, GPPShareDelegate>

@property (nonatomic, retain) ShareGooglePlus* sharer;
@property (assign) long callbackID;

- (id) initWithSharer: (id) sharer andCallbackID: (long) callbackID;

- (void)finishedSharingWithError:(NSError *)error;
- (void)didReceiveDeepLink: (GPPDeepLink *)deepLink;

@end

@implementation GPPShareDelegate

@synthesize callbackID = _callbackID;
@synthesize sharer = _sharer;

- (id) initWithSharer:(id)sharer andCallbackID:(long)callbackID {
    
    if (self = [self init]) {
        self.callbackID = callbackID;
        self.sharer = sharer;
    }
    
    return self;
}

- (void)finishedSharingWithError:(NSError *)error {
    if (!error) {
        [ShareWrapper onShareResult:_sharer withRet:(int) ShareResultCode::kShareSuccess withContent:nil withMsg:@"[Google+] Share succeeded" andCallbackID:_callbackID];
    } else {
        [ShareWrapper onShareResult:_sharer withRet:(int) ShareResultCode::kShareFail withContent:nil withMsg:@"[Google+] Share failed" andCallbackID:_callbackID];
    }
    
    [self release];
}

- (void)didReceiveDeepLink: (GPPDeepLink *)deepLink {
    NSLog(@"deepLinkID = %@", [deepLink deepLinkID]);
}

- (void) dealloc {
    [super dealloc];
    
    [_sharer release];
}

@end

@implementation ShareGooglePlus

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSDictionary*) cpInfo
{
    [GPPDeepLink readDeepLinkAfterInstall];
}

- (void) share:(NSDictionary *)shareInfo withCallback:(long)cbID {
    NSString* urlToShare        = (NSString*) [shareInfo objectForKey:@"urlToShare"];
    NSString* prefillText       = (NSString*) [shareInfo objectForKey:@"prefillText"];
    NSString* deepLinkId        = (NSString*) [shareInfo objectForKey:@"deepLinkId"];
    NSString* contentDeepLinkId = (NSString*) [shareInfo objectForKey:@"contentDeepLinkId"];
    
    GPPShare* sharer = [GPPShare sharedInstance];
    sharer.delegate = [[GPPShareDelegate alloc] initWithSharer:self andCallbackID: cbID];
    
    id<GPPNativeShareBuilder> shareBuilder = [sharer nativeShareDialog];
    
    [shareBuilder setURLToShare:[NSURL URLWithString:urlToShare]];
    [shareBuilder setPrefillText:prefillText];
    [shareBuilder setContentDeepLinkID:contentDeepLinkId];
    
    //http://www.senspark.com/url/gmci
    [shareBuilder setCallToActionButtonWithLabel:@"Download"
                                             URL:[NSURL URLWithString:urlToShare]
                                      deepLinkID:deepLinkId];
    [shareBuilder open];
}

#pragma mark -
- (NSString*) getSessionID
{
    return @"";
}

- (void) setDebugMode: (BOOL) debug
{
    _debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"1.4.1";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}



#pragma mark -
#pragma mark Delegate


@end
