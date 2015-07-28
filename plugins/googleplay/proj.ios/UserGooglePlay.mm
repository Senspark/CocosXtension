//
//  UserGooglePlay.m
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import "UserGooglePlay.h"
#import <gpg/gpg.h>
#import "UserWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation UserGooglePlay

#pragma mark - InterfaceUser

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
    NSString* cliendId = (NSString*) [cpInfo objectForKey:@"GooglePlayAppID"];
    gpg::IosPlatformConfiguration config;
    config.SetClientID(std::string([cliendId cStringUsingEncoding:NSASCIIStringEncoding]));
    config.SetOptionalViewControllerForPopups([UserWrapper getCurrentRootViewController]);
    
    if (!_gameServices) {
        _isSignedIn = false;
        
        OUTPUT_LOG(@"Uninitialized services, so creating");
        _gameServices = gpg::GameServices::Builder().SetOnAuthActionFinished([self](gpg::AuthOperation op, gpg::AuthStatus status) -> void {
            OUTPUT_LOG(@"Sign In finished with a result of %d", (int) status);
            
            switch (status) {
                case gpg::AuthStatus::VALID:
                    _isSignedIn = true;
                    [UserWrapper onActionResult:self withRet:kLoginSucceed withMsg:@"Google Play: login successful"];
                    break;
                case gpg::AuthStatus::ERROR_INTERNAL:
                case gpg::AuthStatus::ERROR_NOT_AUTHORIZED:
                case gpg::AuthStatus::ERROR_TIMEOUT:
                case gpg::AuthStatus::ERROR_VERSION_UPDATE_REQUIRED:
                    [UserWrapper onActionResult:self withRet:kLoginFailed withMsg:@"Google Play: login failed"];
                    _isSignedIn = false;
                    break;
            }
        }).Create(config);
    }
}

- (void) login
{
    if (!_gameServices->IsAuthorized()) {
        OUTPUT_LOG(@"Google Play: Start Authorization UI");
        _gameServices->StartAuthorizationUI();
    } else {
        OUTPUT_LOG(@"Google Play: Logined already!");
    }
}

- (void) logout
{
    if (!_gameServices->IsAuthorized()) {
        OUTPUT_LOG(@"Google Play: Logout");
        _gameServices->SignOut();
    } else {
        OUTPUT_LOG(@"Google Play: Not yet login");
    }
}

- (BOOL) isLogined
{
    return _isSignedIn;
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

@end