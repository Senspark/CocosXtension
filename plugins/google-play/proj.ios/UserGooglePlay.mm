//
//  UserGooglePlay.m
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import "UserGooglePlay.h"

#import <gpg/GooglePlayGames.h>
#import <GooglePlus/GooglePlus.h>

#import "UserWrapper.h"
#import "ProtocolUser.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

using namespace cocos2d::plugin;

@interface UserGooglePlay() <GPGStatusDelegate, GPGStatusDelegate>

@end

@implementation UserGooglePlay

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    _clientID = (NSString*) [cpInfo objectForKey:@"GoogleClientID"];
    [GPGManager sharedInstance].statusDelegate = self;
    [GPGManager sharedInstance].snapshotsEnabled = YES;
    
    [[GPGManager sharedInstance] signInWithClientID:_clientID silently:YES];
}

- (void) login
{
    if (_clientID) {
        [GPGManager sharedInstance].snapshotsEnabled = YES;
        [[GPGManager sharedInstance] signInWithClientID:_clientID silently:NO];
    } else {
        OUTPUT_LOG(@"No Client ID");
    }
}

- (void) logout
{
    [[GPGManager sharedInstance] signOut];
}

- (BOOL) isLoggedIn
{
    return [[GPGManager sharedInstance] isSignedIn];
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
    return @"1.4.1";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

#pragma mark - Interface User of GooglePlay

- (void) beginUserInitiatedSignIn
{
    [self login];
}

#pragma mark -
#pragma mark Delegate

- (void)didFinishGamesSignInWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Received an error while signing in %@", [error localizedDescription]);
        [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"Google Play: login failed"];
    } else {
        NSLog(@"Signed in!");
        [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@"Google Play: login successful"];
    }
}

- (void)didFinishGamesSignOutWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Received an error while signing out %@", [error localizedDescription]);
        [UserWrapper onActionResult:self withRet:kLogoutFailed withMsg:@"Google Play: logout failed"];
    } else {
        NSLog(@"Signed out!");
        [UserWrapper onActionResult:self withRet:kLogoutSucceed withMsg:@"Google Play: logout successful"];
    }
}

- (void)didFinishGoogleAuthWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Received an error while authenticate %@", [error localizedDescription]);
    } else {
        NSLog(@"Authenticate successfully!");
    }
}

@end