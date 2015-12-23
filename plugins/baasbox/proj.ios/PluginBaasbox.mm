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

//implement interfaceBaas

- (void) configDeveloperInfo:(NSDictionary*) devInfo{
    NSString* baseUrl = [devInfo objectForKey:@"baseURL"];
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
                                [BaaSWrapper onBaaSActionResult: self
                                                 withReturnCode: (int)BaaSActionResultCode::kLoginSucceed
                                                   andReturnMsg: @"login baasbox success"
                                                  andCallbackID: cbId];
                            } else {
                                NSLog(@"login baasbox error: %@",error);
                                [BaaSWrapper onBaaSActionResult: self
                                                 withReturnCode: (int)BaaSActionResultCode::kLoginFailed
                                                   andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                  andCallbackID: cbId];
                            }
                        }];
    }else{
        [BaaSWrapper onBaaSActionResult: self
                         withReturnCode: (int)BaaSActionResultCode::kLoginFailed
                           andReturnMsg: @"BAAUser logged in"
                          andCallbackID: cbId];
    }

}

- (void) logout: (long) cbId{
    if([BAAClient sharedClient].isAuthenticated){
        [BAAUser logoutWithCompletion:^(BOOL success, NSError *error) {
            if(success){
                NSLog(@"BAAUser logout success");
                [BaaSWrapper onBaaSActionResult: self
                                 withReturnCode: (int)BaaSActionResultCode::kLogoutSucceed
                                   andReturnMsg: @"logout baasbox success"
                                  andCallbackID: cbId];
            }else{
                NSLog(@"BAAUser logout error %@",error);
                [BaaSWrapper onBaaSActionResult: self
                                 withReturnCode: (int)BaaSActionResultCode::kLogoutFailed
                                   andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                  andCallbackID: cbId];
            }
        }];
    }else{
        [BaaSWrapper onBaaSActionResult: self
                         withReturnCode: (int)BaaSActionResultCode::kLogoutFailed
                           andReturnMsg: @"BAAUser is not authenticated"
                          andCallbackID: cbId];
    }

}

- (BOOL) isLoggedIn{
    return [BAAClient sharedClient].isAuthenticated;
}

- (NSString*) getUserID{
    return [BAAClient sharedClient].currentUser.username;
}

// end implement interfaceBaas


-(void) loginWithFacebookToken:(NSDictionary*) params{
    
    NSString* facebookToken = [params objectForKey:@"Param1"];
    long callbackId = [[params objectForKey:@"Param2"] longValue];
    
    [self loginWithFacebookToken:facebookToken andCallbackId:callbackId];
}

-(void)loginWithFacebookToken:(NSString*)facebookToken andCallbackId:(long)cbId{
    if(facebookToken != NULL){
        [BAAUser loginWithFacebookToken:facebookToken
                             completion:^(BOOL success, NSError *error) {
                                 if (success) {
                                     BAAClient *c = [BAAClient sharedClient];
                                     NSLog(@"login with facebook %@", c.currentUser);
                                     
                                     BAAClient *client = [BAAClient sharedClient];
                                     [client askToEnablePushNotifications];
                                     
                                     [BaaSWrapper onBaaSActionResult: self
                                                      withReturnCode: (int)BaaSActionResultCode::kLoginSucceed
                                                        andReturnMsg: @"login baasbox with facebook token success"
                                                       andCallbackID: cbId];
                                     
                                 } else {
                                     NSLog(@"login with facebook error %@", error);
                                     [BaaSWrapper onBaaSActionResult: self
                                                      withReturnCode: (int)BaaSActionResultCode::kLoginFailed
                                                        andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                       andCallbackID: cbId];
                                 }
                             }];
    }else{
        [BaaSWrapper onBaaSActionResult: self
                         withReturnCode: (int)BaaSActionResultCode::kLoginFailed
                           andReturnMsg: @"facebookToken parameter is NULL"
                          andCallbackID: cbId];
    }
}

-(void) updateUserProfile:(NSDictionary*) params{
    NSLog(@"params %@",params);
    NSString* profile = [params objectForKey:@"Param1"];
    long callbackId   =[[params objectForKey:@"Param2"] longValue];
    
//    NSLog(@"json profile %@",profile);
//    NSLog(@"callback id %ld",callbackId);

    [self updateUserProfile:profile withCallbackId:callbackId];
}

-(void)updateUserProfile:(NSString*)profile withCallbackId:(long)cbId{
    
    BAAUser *user = [[BAAClient sharedClient]currentUser];
    
    NSDictionary* data = [ParseUtils NSStringToArrayOrNSDictionary:profile];
    
    NSMutableDictionary* visibleByRegisterUsers = [data objectForKey:@"visibleByRegisteredUsers"];
    NSMutableDictionary* visibleByTheUser       = [data objectForKey:@"visibleByTheUser"];
    NSMutableDictionary* visibleByAnonymousUsers= [data objectForKey:@"visibleByAnonymousUsers"];
    NSMutableDictionary* visibleByFriends       = [data objectForKey:@"visibleByFriends"];
    
    // set visibleByRegisterUsers
    if(visibleByRegisterUsers){
        [user setVisibleByRegisteredUsers:visibleByRegisterUsers];
    }
    
    // set visibleByTheUsers
    if(visibleByTheUser){
        [user setVisibleByTheUser:visibleByTheUser];
    }
    
    // set visibleByAnonymousUsers
    if(visibleByAnonymousUsers){
        [user setVisibleByAnonymousUsers:visibleByAnonymousUsers];
    }
    
    // set visibleByFriends
    if(visibleByFriends){
        [user setVisibleByFriends:visibleByFriends];
    }
    
    [user updateWithCompletion:^(BAAUser *user, NSError *error) {
        if (error == nil) {
            NSLog(@"update user profile success");
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: (int)BaaSActionResultCode::kSaveSucceed
                               andReturnMsg: @"update user profile success"
                              andCallbackID: cbId];
        } else {
            NSLog(@"update user profile %@", error);
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: (int)BaaSActionResultCode::kSaveFailed
                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                              andCallbackID:  cbId];
        }
    }];
    
}

-(void)fetchUserProfileWithCallbackId:(NSNumber*)cbId{
    long _cbId = cbId ? [cbId longValue] : 0;
    
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
                
                [BaaSWrapper onBaaSActionResult: self
                                 withReturnCode: (int)BaaSActionResultCode::kRetrieveSucceed
                                   andReturnMsg: NSJsonData
                                  andCallbackID: _cbId];
            }else{
                NSLog(@"BAAUser null");
                [BaaSWrapper onBaaSActionResult: self
                                 withReturnCode: (int)BaaSActionResultCode::kRetrieveFailed
                                   andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                  andCallbackID: _cbId];
            }
        }];
    }else{
        [BaaSWrapper onBaaSActionResult: self
                         withReturnCode: (int)BaaSActionResultCode::kRetrieveFailed
                           andReturnMsg: @"BAAUser is not authenticated"
                          andCallbackID: _cbId];
    }
}

//-(void) registerForRemoteNotifications:(NSString*) params{
//    NSDictionary* dic = [ParseUtils NSStringToArrayOrNSDictionary:params];
//    
//    NSData* deviceToken = [dic objectForKey:@"deviceToken"];
//    long callbackId = [[dic objectForKey:@"callbackId"] longValue];
//    
//    [self registerForRemoteNotificationsWithDeviceToken:deviceToken andCallbackId:callbackId];
//}

-(void) registerForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken andCallbackId:(long) cbId{
    BAAClient *client = [BAAClient sharedClient];
    [client enablePushNotifications:deviceToken completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"register remote notification success");
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: (int)BaaSActionResultCode::kRegisterForRemoteNotificationsSuccessed
                               andReturnMsg: @"register success"
                              andCallbackID: cbId];
        }else{
            NSLog(@"register remote notification : %@",error);
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: (int)BaaSActionResultCode::kRegisterForRemoteNotificationsFailed
                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                              andCallbackID: cbId];
        }
    }];
}


-(void) fetchScoresFriendsFacebook:(NSDictionary*) params{
//    NSLog(@"params fetchscoaresFriendsFB : %@",params);
    NSString* facebookPlayers = [params objectForKey:@"Param1"];
    NSMutableArray* players = [[ParseUtils NSStringToArrayOrNSDictionary:facebookPlayers] mutableCopy];
    long callbackId = [[params objectForKey:@"Param2"] longValue];
    [self fetchScoresFriendsFacebookWithPlayers:players andCallbackId:callbackId];
}

-(void)fetchScoresFriendsFacebookWithPlayers:(NSMutableArray*)players andCallbackId:(long)cbId{
//    NSLog(@"players : %@",players);
//    NSLog(@"cbid : %ld",cbId);
    
    NSMutableArray* facebookIdList = [[NSMutableArray alloc] init] ;
    
    for(NSMutableDictionary *p in players){
        NSString* facebookId = [p objectForKey:@"id"];
        [facebookIdList addObject:facebookId];
    }
    
    if(facebookIdList){
        
        NSString* strFacebookIdList = [ParseUtils NSDictionaryToNSString:facebookIdList];
        
        NSString* conditionWhere = [NSString stringWithFormat:@"visibleByRegisteredUsers._social.facebook.id in %@",strFacebookIdList];
        
        NSDictionary *params = @{@"where" : conditionWhere};
        
        [BAAUser loadUsersWithParameters:params
                              completion:^(NSArray *users, NSError *error) {
                                  if (users) {
                                      for (BAAUser* user in users) {
                                          NSDictionary* visibleByRegisterUser = user.visibleByRegisteredUsers;
                                          NSString* nsFBId = [[[visibleByRegisterUser objectForKey:@"_social"] objectForKey:@"facebook"] objectForKey:@"id"];
                                          NSArray* nsScores = [visibleByRegisterUser objectForKey:@"scores"];
//                                          NSLog(@"ns score  %@",nsScores);
                                          if(nsScores){
                                              for(NSMutableDictionary * p in players){
                                                  NSString* facebookId = [p objectForKey:@"id"];
//                                                  NSLog(@"facebook id %@",facebookId);
//                                                  NSLog(@"ns facebook id %@",nsFBId);
                                                  if([facebookId isEqualToString:nsFBId]){
                                                      [p setObject:nsScores forKey:@"scores"];
                                                  }
                                              }
                                          }
                                      }
                                      
                                      NSString* NSJsonData = [ParseUtils NSDictionaryToNSString:players];
                                      
                                      [BaaSWrapper onBaaSActionResult: self
                                                       withReturnCode: (int)BaaSActionResultCode::kRetrieveSucceed
                                                         andReturnMsg: NSJsonData
                                                        andCallbackID: cbId];
                                  } else {
                                      NSLog(@"fetch score facebook friends fail: %@",error);
                                      [BaaSWrapper onBaaSActionResult: self
                                                       withReturnCode: (int)BaaSActionResultCode::kRetrieveFailed
                                                         andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                        andCallbackID: cbId];
                                  }
                              }];
    }else{
        NSLog(@"facebook id list NULL");
        [BaaSWrapper onBaaSActionResult: self
                         withReturnCode: (int)BaaSActionResultCode::kRetrieveFailed
                           andReturnMsg: @"players facebook parameter is NULL"
                          andCallbackID: cbId];
    }
    
}



@end
