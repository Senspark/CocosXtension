/****************************************************************************
 Copyright (c) 2014 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "UserFacebook.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UserWrapper.h"
#import "ProtocolUser.h"
#import "ParseUtils.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

using namespace cocos2d::plugin;

@implementation UserFacebook


//@synthesize mUserInfo;
@synthesize debug = __debug;
@synthesize permissions = _permissions;

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo{
}

- (void) login {
    self.permissions = @[@"public_profile", @"email", @"user_friends"];
    [self loginWithReadPermissionsInArray:_permissions];
}

- (void) loginWithReadPermissions: (NSString *) permissions {
    self.permissions = [permissions componentsSeparatedByString:@","];
    [self loginWithReadPermissionsInArray:_permissions];
}

- (void) loginWithPublishPermissions: (NSString *) permissions {
    self.permissions = [permissions componentsSeparatedByString:@","];
    [self loginWithPublishPermissionsInArray:_permissions];
}

- (void) onLoginResult: (FBSDKLoginManagerLoginResult*) result error: (NSError*) error {
    if (error) {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLoginFailed withMsg:error.description];
    } else if (result.isCancelled) {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLoginFailed withMsg:@"Login facebook: user cancel"];
    } else if (result.declinedPermissions.count > 0) {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLoginFailed withMsg:@"Permission declined"];
    } else {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLoginSucceed withMsg:@"Login facebook success"];
    }
}

- (void) loginWithReadPermissionsInArray:(NSArray *) permission {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:permission handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        [self onLoginResult:result error: error];
    }];
}

- (void) loginWithPublishPermissionsInArray:(NSArray *) permission {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithPublishPermissions:permission handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        [self onLoginResult:result error: error];
    }];
}

- (void) logout{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
        
        [UserWrapper onActionResult:self withRet: (int)([self isLoggedIn] ? UserActionResultCode::kLogoutFailed : UserActionResultCode::kLogoutSucceed) withMsg:@"Facebook logout"];
    } else {
        [UserWrapper onActionResult:self withRet: (int) UserActionResultCode::kLogoutFailed withMsg:@"Not login yet."];
    }
}

- (NSString *) getUserID {
    return [FBSDKAccessToken currentAccessToken].userID;
}

-(NSString*) getUserFullName {
    NSLog(@"user name %@",[FBSDKProfile currentProfile].name);
    return [FBSDKProfile currentProfile].name;
}

-(NSString*) getUserLastName {
    NSLog(@"user last name %@", [[FBSDKProfile currentProfile] lastName]);
    return [[FBSDKProfile currentProfile] lastName];
}

-(NSString*) getUserFirstName {
    NSLog(@"user first name %@", [[FBSDKProfile currentProfile] firstName]);
    return [[FBSDKProfile currentProfile] firstName];
}

- (BOOL) isLoggedIn{
    return [FBSDKAccessToken currentAccessToken] ? YES : NO;
}

-(NSString *) getPermissionList {
    NSSet* permissions = [FBSDKAccessToken currentAccessToken].permissions;
    return [[permissions allObjects] componentsJoinedByString:@","];
}

-(NSString *)getAccessToken{
    return [FBSDKAccessToken currentAccessToken].tokenString;
}

- (NSString*) getSessionID{
    return @"";
}

- (void) setDebugMode: (BOOL) debug{
    __debug = debug;
}

- (void) graphRequestWithParams:(NSDictionary *)params {
    NSString *graphPath = [params objectForKey:@"Param1"];
    NSDictionary* graphParams =[params objectForKey:@"Param2"];
    long cbid = [[params objectForKey:@"Param3"] longValue];
    
    [self graphRequestWithGraphPath:graphPath parameters:graphParams callback:cbid];
}

- (void) graphRequestWithGraphPath: (NSString*) graphPath parameters: (NSDictionary*) params callback: (long) cbid {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:params]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
//                 NSLog(@"Fetch facebook info:%@", result);
                 
                 [UserWrapper onGraphRequestResultFrom:self withRet: (int) GraphResult::kGraphResultSuccess result:result andCallback:cbid];
                 
             } else {
                 
//                 NSLog(@"Fetch facebook info error: %@", error.description);
                 
                 [UserWrapper onGraphRequestResultFrom:self withRet: (int) GraphResult::kGraphResultFail result:result andCallback:cbid];
             }
         }];
    } else {
        [UserWrapper onGraphRequestResultFrom:self withRet: (int) GraphResult::kGraphResultFail result:nil andCallback:cbid];
    }
}

-(void) api: (NSMutableDictionary *)params{
    NSString *graphPath = [params objectForKey:@"Param1"];
    int methodID = [[params objectForKey:@"Param2"] intValue];
    NSString * method = methodID == 0? @"GET":methodID == 1?@"POST":@"DELETE";
    NSDictionary *param = [params objectForKey:@"Param3"];
    long cbId = [[params objectForKey:@"Param4"] longValue];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:param HTTPMethod:method];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        if(!error){
            NSString *msg = [ParseUtils NSDictionaryToNSString:(NSDictionary *)result];
            if(nil == msg){
                NSString *msg = [ParseUtils MakeJsonStringWithObject:@"parse result failed" andKey:@"error_message"];
                [UserWrapper onGraphResult:self withRet: (int) GraphResult::kGraphResultFail withMsg:msg withCallback:cbId];
            }else{
                OUTPUT_LOG(@"success");
                [UserWrapper onGraphResult:self withRet: (int) GraphResult::kGraphResultSuccess withMsg:msg withCallback:cbId];
            }
        }else{
            NSString *msg = [ParseUtils MakeJsonStringWithObject:error.description andKey:@"error_message"];
            [UserWrapper onGraphResult:self withRet: (int) GraphResult::kGraphResultFail withMsg:msg withCallback:cbId];
            OUTPUT_LOG(@"error %@", error.description);
        }
    }];
}



- (NSString*) getSDKVersion{
    return [FBSDKSettings sdkVersion];
}

- (NSString*) getPluginVersion{
    return @"0.1.0";
}


@end
