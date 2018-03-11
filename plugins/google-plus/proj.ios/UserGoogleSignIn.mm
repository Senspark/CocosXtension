//
//  UserGoogleSignIn.cpp
//  PluginGooglePlus
//
//  Created by Senspark-Dev5 on 9/8/17.
//  Copyright © 2017 Senspark. All rights reserved.
//

#import "UserGoogleSignIn.h"
#import "UserWrapper.h"
#import "ProtocolUser.h"

#import <GoogleSignIn/GoogleSignIn.h>

using namespace cocos2d::plugin;

@interface UserGoogleSignIn() <GIDSignInDelegate, GIDSignInUIDelegate>

@end

@implementation UserGoogleSignIn

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSDictionary*) cpInfo
{
    NSString* _clientID = (NSString*) [cpInfo objectForKey:@"GoogleClientID"];
    [GIDSignIn sharedInstance].clientID = _clientID;
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    
    if ([self isLoggedIn])
    {
        [[GIDSignIn sharedInstance] signInSilently];
    }
    
}

- (void) login
{
    [[GIDSignIn sharedInstance] signIn];
}

- (void) logout
{
    [[GIDSignIn sharedInstance] disconnect];
    
}

- (BOOL) isLoggedIn
{
    return [[GIDSignIn sharedInstance] hasAuthInKeychain];
    
}

- (NSString*) getSessionID
{
    return @"";
}

#pragma mark - Interface User of GooglePlay
- (NSString*) getUserAvatarUrl {
    
    return [[[GIDSignIn sharedInstance].currentUser.profile imageURLWithDimension:50] absoluteString];
    
}

- (NSString*) getUserID {
    
    return [GIDSignIn sharedInstance].currentUser.userID;
}

- (NSString*) getUserDisplayName {
    
    return [GIDSignIn sharedInstance].currentUser.profile.name;
    
}


- (void) setDebugMode: (BOOL) debug {}

- (NSString*) getSDKVersion {
    return @"";
}

- (NSString*) getPluginVersion {
    return @"";
}


//-------------------------------------------------------------------------------
// Stop the UIActivityIndicatorView animation that was started when the user
// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    //[myActivityIndicator stopAnimating];
    
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    
    [[UserWrapper getCurrentRootViewController] presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [[UserWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:nil];
}
//-------------------------------------------------------------------------------

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    //    // Perform any operations on signed in user here.
    //    NSString *userId = user.userID;                  // For client-side use only!
    //    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    //    NSString *fullName = user.profile.name;
    //    NSString *givenName = user.profile.givenName;
    //    NSString *familyName = user.profile.familyName;
    //    NSString *email = user.profile.email;
    //    // ...

    if (error) {
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginFailed withMsg:@"Login Google failed"];
    } else {
        [UserWrapper onActionResult:self withRet:(int)UserActionResultCode::kLoginSucceed withMsg:@"Login Google succeeded"];
    }
    
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error) {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLogoutFailed withMsg:@"Logout Google failed"];
    } else {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLogoutSucceed withMsg:@"Logout Google."];
    }
}



@end
