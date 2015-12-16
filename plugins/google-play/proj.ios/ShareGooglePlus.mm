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

@interface ShareGooglePlus() <GPPDeepLinkDelegate, GPPShareDelegate>

@end

@implementation ShareGooglePlus

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    // init G+
    [GPPDeepLink setDelegate: self];
    [GPPDeepLink readDeepLinkAfterInstall];
}

- (void) share:(NSMutableDictionary *)shareInfo {

    NSString* urlToShare        = (NSString*) [shareInfo objectForKey:@"urlToShare"];
    NSString* prefillText       = (NSString*) [shareInfo objectForKey:@"prefillText"];
    NSString* deepLinkId        = (NSString*) [shareInfo objectForKey:@"deepLinkId"];
    NSString* contentDeepLinkId = (NSString*) [shareInfo objectForKey:@"contentDeepLinkId"];

    [[GPPShare sharedInstance] setDelegate: self]; //set delegate for GPPShare
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];

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
- (void)finishedSharingWithError:(NSError *)error {
    if (!error) {
        [ShareWrapper onShareResult:self withRet:(int) ShareResultCode::kShareSuccess withContent:nil withMsg:@"[Google+] Share succeeded"];
    } else {
        [ShareWrapper onShareResult:self withRet:(int) ShareResultCode::kShareFail withContent:nil withMsg:@"[Google+] Share failed"];
    }
}

- (void)didReceiveDeepLink: (GPPDeepLink *)deepLink {
    NSLog(@"deepLinkID = %@", [deepLink deepLinkID]);
}

@end
