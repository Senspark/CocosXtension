//
//  PluginBaasbox.m
//  PluginBaasbox
//
//  Created by Tran Van Tuan on 12/21/15.
//  Copyright © 2015 Senspark. All rights reserved.
//

#import "PluginBaasbox.h"
#import "BAAClient.h"
#import "BaaSWrapper.h"
#import "ProtocolBaaS.h"

#import "ParseUtils.h"

using namespace cocos2d::plugin;

@implementation PluginBaasbox

- (void) configDeveloperInfo:(NSDictionary*) devInfo{
    NSString* baseUrl = [devInfo objectForKey:@"baseUrl"];
    NSString* appCode = [devInfo objectForKey:@"appCode"];
    
    [BaasBox setBaseURL:baseUrl
                appCode:appCode];
}

- (void) signUpWithParams: (NSDictionary*) params andCallbackID: (long) cbId{
    
}

- (void) loginWithUsername: (NSString*) username andPassword: (NSString*) password andCallbackID: (long) cbId{
    if(![self isLoggedIn]){
        [BAAUser loginWithUsername:username
                          password:password
                        completion:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"login baasbox success");
                                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLoginSucceed andReturnMsg:@"login baasbox success" andCallbackID:cbId];
                            } else {
                                NSLog(@"login baasbox error: %@",error);
                                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLoginFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
                            }
                        }];
    }

}

- (void) logout: (long) cbId{
    if([BAAClient sharedClient].isAuthenticated){
        [BAAUser logoutWithCompletion:^(BOOL success, NSError *error) {
            if(success){
                NSLog(@"BAAUser logout success");
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLogoutSucceed andReturnMsg:@"logout baasbox success" andCallbackID:cbId];
            }else{
                NSLog(@"BAAUser logout error %@",error);
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLogoutFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
            }
        }];
    }

}

- (BOOL) isLoggedIn{
    return [BAAClient sharedClient].isAuthenticated;
}

- (NSString*) getUserId{
    return @"";
}

-(void)loginWithFacebookToken:(NSString*)facebookToken andCallbackId:(int)cbId{
    if(facebookToken != NULL){
        [BAAUser loginWithFacebookToken:facebookToken
                             completion:^(BOOL success, NSError *error) {
                                 if (success) {
                                     BAAClient *c = [BAAClient sharedClient];
                                     NSLog(@"login with facebook %@", c.currentUser);
                                     
                                     BAAClient *client = [BAAClient sharedClient];
                                     [client askToEnablePushNotifications];
                                     
                                     [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLoginSucceed andReturnMsg:@"login baasbox with facebook token success" andCallbackID:cbId];
                                     
                                 } else {
                                     NSLog(@"login with facebook error %@", error);
                                     [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kLoginFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
                                 }
                             }];
    }
}

-(void)updateProfileUser:(NSString*)jsonData withCallbackId:(int)cbId{
    
    BAAUser *user = [[BAAClient sharedClient]currentUser];
    
    NSDictionary* data = [ParseUtils NSStringToArrayOrNSDictionary:jsonData];
    
    NSDictionary* visibleByRegisterUsers = [data objectForKey:@"visibleByRegisteredUsers"];
    NSDictionary* visibleByTheUser       = [data objectForKey:@"visibleByTheUser"];
    NSDictionary* visibleByAnonymousUsers= [data objectForKey:@"visibleByAnonymousUsers"];
    NSDictionary* visibleByFriends       = [data objectForKey:@"visibleByFriends"];
    
    // set visibleByRegisterUsers
    if(visibleByRegisterUsers){
        NSArray* keysVisibleByRegisterUsers  = [visibleByRegisterUsers allKeys];
        for(NSString* key : keysVisibleByRegisterUsers){
            [user.visibleByRegisteredUsers setObject:[visibleByRegisterUsers objectForKey:key] forKey:key];
        }
    }
    
    // set visibleByTheUsers
    if(visibleByTheUser){
        NSArray* keysVisibleByTheUser        = [visibleByTheUser allKeys];
        for(NSString* key : keysVisibleByTheUser){
            [user.visibleByTheUser setObject:[visibleByTheUser objectForKey:key] forKey:key];
        }
    }
    
    // set visibleByAnonymousUsers
    if(visibleByAnonymousUsers){
        NSArray* keysVisibleByAnonymousUsers = [visibleByAnonymousUsers allKeys];
        for(NSString* key : keysVisibleByAnonymousUsers){
            [user.visibleByAnonymousUsers setObject:[visibleByAnonymousUsers objectForKey:key] forKey:key];
        }
    }
    
    // set visibleByFriends
    if(visibleByFriends){
        NSArray* keysVisibleByFriends        = [visibleByFriends allKeys];
        for(NSString* key : keysVisibleByFriends){
            [user.visibleByFriends setObject:[visibleByFriends objectForKey:key] forKey:key];
        }
    }
    
    [user updateWithCompletion:^(BAAUser *user, NSError *error) {
        if (error == nil) {
            NSLog(@"update user profile success");
            [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kSaveSucceed andReturnMsg:@"update user profile success" andCallbackID:cbId];
        } else {
            NSLog(@"update user profile %@", error);
            [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kSaveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
        }
    }];
    
}

-(void)fetchProfileUserWithCallbackId:(int)cbId{
    
    if([BAAClient sharedClient].isAuthenticated){
        
        [BAAUser loadCurrentUserWithCompletion:^(BAAUser*  object, NSError *error) {
            
            if(object){
                NSLog(@"load current user : %@",object);
                
                NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
                
                [userInfo setObject:object.visibleByRegisteredUsers forKey:@"visibleByRegisteredUsers"];
                [userInfo setObject:object.visibleByTheUser         forKey:@"visibleByTheUser"];
                [userInfo setObject:object.visibleByAnonymousUsers  forKey:@"visibleByAnonymousUsers"];
                [userInfo setObject:object.visibleByFriends         forKey:@"visibleByFriends"];
                
                NSString* NSJsonData = [ParseUtils NSDictionaryToNSString:userInfo];
                
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kRetrieveSucceed andReturnMsg:NSJsonData andCallbackID:cbId];
            }else{
                NSLog(@"BAAUser null");
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kRetrieveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
            }
        }];
    }
}






@end
