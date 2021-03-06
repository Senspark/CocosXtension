//
//  UserGameCenter.m
//  PluginGameCenter
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "UserGameCenter.h"
#import "ProtocolUser.h"
#import "UserWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation UserGameCenter

#pragma mark -
#pragma mark Interface User

using namespace cocos2d::plugin;

- (void) configDeveloperInfo : (NSDictionary*) cpInfo
{
}

- (void) login
{
    if ([[GKLocalPlayer class] instancesRespondToSelector:@selector(setAuthenticateHandler:)]) {
        [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *controller, NSError *error) {
            if (controller) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[UserWrapper getCurrentRootViewController] presentViewController:controller animated:YES completion:nil];
                });
            } else if ([GKLocalPlayer localPlayer].isAuthenticated) {
                NSLog(@"Signed in!");
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginSucceed withMsg:@"Game Center: login successful"];
                });
            } else {
//            if (error) {
                NSLog(@"Received an error while signing in %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginFailed withMsg:@"Game Center: login failed"];
                });
          }
        }];
    } else {    //iOS < 6
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Received an error while signing in %@", [error localizedDescription]);
                [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginFailed withMsg:@"Game Center: login failed"];
            } else {
                NSLog(@"Signed in!");
                [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginSucceed withMsg:@"Game Center: login successful"];
            }
        }];
#pragma GCC diagnostic pop
    }
    
}

- (void) logout
{
    NSLog(@"Can not logout game center programmatically.");
}

- (BOOL) isLoggedIn
{
    return [GKLocalPlayer localPlayer].authenticated;
}

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
    return @"8";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

@end
