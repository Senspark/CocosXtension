//
//  UserGooglePlus.mm
//  UserGooglePlus
//
//  Created by Nikel Arteta on 1/6/16.
//  Copyright © 2016 Senspark. All rights reserved.
//

#import "UserGooglePlus.h"
#import "UserWrapper.h"
#import "ProtocolUser.h"

#define OUTPUT_LOG(...) if (self.debug) NSLong(__VA_ARGS__);

using namespace cocos2d::plugin;

@interface UserGooglePlus() <GPPSignInDelegate>

@end

@implementation UserGooglePlus

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    _clientID = (NSString*) [cpInfo objectForKey:@"GoogleClientID"];

    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.shouldFetchGoogleUserID = YES;

    // You previously set kClientId in the "Initialize the Google+ client" step
    signIn.clientID = _clientID;

    // Uncomment one of these two statements for the scope you chose in the previous step
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope

    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;

    [signIn trySilentAuthentication];
}

- (void) login
{
    if (_clientID) {
        [[GPPSignIn sharedInstance] authenticate];
    } else {
        NSLog(@"No Client ID");
    }
}

- (void) logout
{
    [[GPPSignIn sharedInstance] signOut];
}

- (BOOL) isLoggedIn
{
    return [[GPPSignIn sharedInstance] hasAuthInKeychain];
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
- (NSString*) getUserAvatarUrl {
    return [GPPSignIn sharedInstance].googlePlusUser.image.url;
}

- (NSString*) getUserID {
    return [GPPSignIn sharedInstance].googlePlusUser.identifier;
}

- (NSString*) getUserDisplayName {
    return [GPPSignIn sharedInstance].googlePlusUser.displayName;
}

- (void) beginUserInitiatedSignIn
{
    [self login];
}



#pragma mark -
#pragma mark Delegate
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                  error:(NSError *)error {
    if (error) {
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginFailed withMsg:@"[Google+] Login failed"];
    } else {
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginSucceed withMsg:@"[Google+] Login succeeded"];
    }
}

- (void)didFinishGamesSignInWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Received an error while signing in %@", [error localizedDescription]);
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginFailed withMsg:@"Google Play: login failed"];
    } else {
        NSLog(@"Signed in!");
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginSucceed withMsg:@"Google Play: login successful"];
    }
}

- (void)didFinishGamesSignOutWithError:(NSError *)error
{
    if (error) {
        NSLog(@"Received an error while signing out %@", [error localizedDescription]);
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLogoutFailed withMsg:@"Google Play: logout failed"];
    } else {
        NSLog(@"Signed out!");
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLogoutSucceed withMsg:@"Google Play: logout successful"];
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
