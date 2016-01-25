//
//  BaaSBaasbox.m
//  BaaSBaasbox
//
//  Created by Tran Van Tuan on 12/21/15.
//  Copyright © 2015 Senspark. All rights reserved.
//

#import "BaaSBaasbox.h"
#import "BAAClient.h"
#import "BaaSWrapper.h"
#import "ProtocolBaaS.h"

#import "ParseUtils.h"


using namespace cocos2d::plugin;

@implementation BaaSBaasbox

//implement interfaceBaas

- (void) configDeveloperInfo:(NSDictionary*) devInfo{
    NSString* domain  = [devInfo objectForKey:@"domain"];
    NSString* port    = [devInfo objectForKey:@"port"];
    NSString* appCode = [devInfo objectForKey:@"appCode"];
    
    NSString* baseUrl = [[[@"http://" stringByAppendingString:domain] stringByAppendingString:@":"] stringByAppendingString:port];
    NSLog(@"baseUrl of baasbox server is : %@", baseUrl);
    
    [BaasBox setBaseURL:baseUrl
                appCode:appCode];
}

- (void) signUpWithParams: (NSDictionary*) params andCallbackID: (long) cbId{
    NSString* username = [params objectForKey:@"username"];
    NSString* password = [params objectForKey:@"password"];
    
    BAAClient *client = [BAAClient sharedClient];
    [client createUserWithUsername:username
                          password:password
                        completion:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"user is %@", client.currentUser);
                                [BaaSWrapper onBaaSActionResult: self
                                                 withReturnCode: true
                                                   andReturnMsg: @"signup user baasbox success"
                                                  andCallbackID: cbId];
                            } else {
                                [BaaSWrapper onBaaSActionResult: self
                                                 withReturnCode: false
                                                   andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                  andCallbackID: cbId];

                            }
                            
                        }];
}

- (void) loginWithUsername: (NSString*) username andPassword: (NSString*) password andCallbackID: (long) cbId{
    [BAAUser loginWithUsername:username
                      password:password
                    completion:^(BOOL success, NSError *error) {
                        if (success) {
                            NSLog(@"login baasbox success");
                            [BaaSWrapper onBaaSActionResult: self
                                             withReturnCode: true
                                               andReturnMsg: @"login baasbox success"
                                              andCallbackID: cbId];
                        } else {
                            NSLog(@"login baasbox error: %@",error);
                            [BaaSWrapper onBaaSActionResult: self
                                             withReturnCode: false
                                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                              andCallbackID: cbId];
                        }
                    }];
    
    
}

- (void) logout: (long) cbId{
    [BAAUser logoutWithCompletion:^(BOOL success, NSError *error) {
        if(success){
            NSLog(@"BAAUser logout success");
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: true
                               andReturnMsg: @"logout baasbox success"
                              andCallbackID: cbId];
        }else{
            NSLog(@"BAAUser logout error %@",error);
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: false
                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                              andCallbackID: cbId];
        }
    }];
}

- (BOOL) isLoggedIn{
    
//    NSDictionary* dic = [BAAClient sharedClient].currentUser.visibleByRegisteredUsers;
//    NSLog(@"visibleByRegisterUsers : %@", dic);
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
    
    [BAAUser loginWithFacebookToken:facebookToken
                         completion:^(BOOL success, NSError *error) {
                             if (success) {
                                 BAAClient *c = [BAAClient sharedClient];
                                 NSLog(@"login with facebook %@", c.currentUser);
                                 
                                 BAAClient *client = [BAAClient sharedClient];
                                 [client askToEnablePushNotifications];
                                 
                                 [BaaSWrapper onBaaSActionResult: self
                                                  withReturnCode: true
                                                    andReturnMsg: @"login baasbox with facebook token success"
                                                   andCallbackID: cbId];
                                 
                             } else {
                                 NSLog(@"login with facebook error %@", error);
                                 [BaaSWrapper onBaaSActionResult: self
                                                  withReturnCode: false
                                                    andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                   andCallbackID: cbId];
                             }
                         }];
    
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
                             withReturnCode: true
                               andReturnMsg: @"update user profile success"
                              andCallbackID: cbId];
        } else {
            NSLog(@"update user profile %@", error);
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: false
                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                              andCallbackID:  cbId];
        }
    }];
    
}

-(void)fetchUserProfileWithCallbackId:(NSNumber*)cbId{
    long _cbId = cbId ? [cbId longValue] : 0;
    
    
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
                             withReturnCode: true
                               andReturnMsg: NSJsonData
                              andCallbackID: _cbId];
        }else{
            NSLog(@"BAAUser null");
            [BaaSWrapper onBaaSActionResult: self
                             withReturnCode: false
                               andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                              andCallbackID: _cbId];
        }
    }];
}

-(void) registerForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken completion:(void(^)(BOOL))successed{
    BAAClient *client = [BAAClient sharedClient];
    [client enablePushNotifications:deviceToken completion:^(BOOL success, NSError *error) {
        successed(success);
    }];
}


-(void) loadUsersWithParameters:(NSDictionary*) params{
//    NSLog(@"params fetchscoaresFriendsFB : %@",params);
    NSString* condition = [params objectForKey:@"Param1"];
  
    long callbackId = [[params objectForKey:@"Param2"] longValue];
    
    [self loadUsersWithParameters:condition andCallbackId:callbackId];
}

-(void)loadUsersWithParameters:(NSString*)condition andCallbackId:(long)cbId{
//    NSString* conditionWhere = [NSString stringWithFormat:@"visibleByRegisteredUsers._social.facebook.id in %@",strFacebookIdList];
    NSDictionary *params = @{@"where" : condition};
    
    [BAAUser loadUsersWithParameters:params
                          completion:^(NSArray *users, NSError *error) {
                              if (users) {
                                  NSLog(@"users baasbox : %@",users);
                                  NSMutableArray* arr = [[NSMutableArray alloc] init];
                                  for (BAAUser* user in users) {
                                      NSDictionary* u = [ self BAAUserToNSDictionary:user];
                                      [arr addObject:u];
                                  }
                                  NSLog(@"Arr : %@",arr);
                                  
                                  NSString* NSUsers = [ParseUtils NSDictionaryToNSString:arr];
                                   NSLog(@"NS users baasbox : %@",NSUsers);
                                  [BaaSWrapper onBaaSActionResult: self
                                                   withReturnCode: true
                                                     andReturnMsg: NSUsers
                                                    andCallbackID: cbId];
                              } else {
                                  NSLog(@"fetch score facebook friends fail: %@",error);
                                  [BaaSWrapper onBaaSActionResult: self
                                                   withReturnCode: false
                                                     andReturnMsg: [BaaSWrapper makeErrorJsonString:error]
                                                    andCallbackID: cbId];
                              }
                          }];
}

-(NSDictionary*)BAAUserToNSDictionary:(BAAUser*) user{
    NSString* status = user.status;
//    NSString* name   = user.username;
    NSDictionary* roles = user.roles;
    NSDictionary *visibleByTheUser = user.visibleByTheUser;
    NSDictionary *visibleByFriends = user.visibleByFriends;
    NSDictionary *visibleByRegisteredUsers = user.visibleByRegisteredUsers;
    NSDictionary *visibleByAnonymousUsers = user.visibleByAnonymousUsers;
    
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    [ret setObject:status forKey:@"status"];
//    [ret setObject:name forKey:@"username"];
    [ret setObject:roles forKey:@"roles"];
    [ret setObject:visibleByAnonymousUsers forKey:@"visibleByAnonymousUsers"];
    [ret setObject:visibleByRegisteredUsers forKey:@"visibleByRegisteredUsers"];
    [ret setObject:visibleByFriends forKey:@"visibleByFriends"];
    [ret setObject:visibleByTheUser forKey:@"visibleByTheUser"];
    
    return ret;
}

// collection

//class == collection
- (void) saveObjectInBackground: (NSString*) className withParams: (NSDictionary*) obj andCallbackID:(long) cbID{
    BAAClient* client = [BAAClient sharedClient];
    [client postPath:[NSString stringWithFormat:@"document/%@", className]
        parameters:obj
           success:^(id responseObject) {
               
               NSDictionary *d = responseObject[@"data"];
               [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:d andCallbackID:cbID];
               
           } failure:^(NSError *error) {
               
               [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
               
           }];
}

- (NSString*) saveObject: (NSString*) className withParams: (NSDictionary*) obj{
    return @"Baasbox is not support";
}

//private method
-(void)getPath:(NSString*)path parameters:(NSDictionary*)params callbackId:(long)cbId{
    BAAClient* client = [BAAClient sharedClient];
    [client getPath:path
         parameters:params
            success:^(id responseObject) {
                
                NSDictionary *d = responseObject[@"data"];
                
                if (d) {
                    
                    [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:d andCallbackID:cbId];
                    
                } else {
                    
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    [errorDetail setValue:responseObject[@"message"]
                                   forKey:NSLocalizedDescriptionKey];
                    NSError *error = [NSError errorWithDomain:[BaasBox errorDomain]
                                                         code:[BaasBox errorCode]
                                                     userInfo:errorDetail];
                    [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
                    
                }
                
            } failure:^(NSError *error) {
                
                [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
                
            }];

}

- (void) getObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID{
    
    [self getPath:[NSString stringWithFormat:@"document/%@/%@", className, objId]
       parameters:nil
       callbackId:cbID];

}

- (void) getObjectsInBackground: (NSString*) className withIds: (NSArray*) objIds andCallbackID:(long) cbID{
    
    NSString* conditionWhere = [NSString stringWithFormat:@"id in %@",[ParseUtils NSDictionaryToNSString:objIds]];
    NSDictionary *params = @{@"where" : conditionWhere};
    NSLog(@"params : %@",params);
    
    [self getPath:[NSString stringWithFormat:@"document/%@", className]
       parameters:params
       callbackId:cbID];

}

- (NSDictionary*) getObject: (NSString*) className withId: (NSString*) objId{
    return NULL;
}

- (void) fetchObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID{
    [self getObjectInBackground:className withId:objId andCallbackID:cbID];
}

- (void) findObjectInBackground: (NSString*) className whereKey: (NSString*) key equalTo: (NSString*) value    withCallbackID: (long) callbackId{
    NSString* conditionWhere = [NSString stringWithFormat:@"%@ = '%@'",key,value];
    NSLog(@"condition where : %@",conditionWhere);
    NSDictionary *params = @{@"where" : conditionWhere};
    NSLog(@"params : %@",params);
    
    [self getPath:[NSString stringWithFormat:@"document/%@", className]
       parameters:params
       callbackId:callbackId];
    
}

- (void) findObjectsInBackground: (NSString*) className whereKey: (NSString*) key containedIn: (NSArray*) values    withCallbackID: (long) callbackId{
    
    NSString* conditionWhere = [NSString stringWithFormat:@"%@ in %@",key,[ParseUtils NSDictionaryToNSString:values]];
    NSDictionary *params = @{@"where" : conditionWhere};
    NSLog(@"params : %@",params);
    
    [self getPath:[NSString stringWithFormat:@"document/%@", className]
       parameters:params
       callbackId:callbackId];
}

- (void) updateObjectInBackground: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params andCallbackID:(long) cbID{
    NSLog(@"params : %@",params);
    
    BAAClient *client = [BAAClient sharedClient];
    [client putPath:[NSString stringWithFormat:@"document/%@/%@", className, objId]
       parameters:params
          success:^(id responseObject) {
              
              NSDictionary *d = responseObject[@"data"];
              [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:d andCallbackID:cbID];
              
          } failure:^(NSError *error) {
              
              [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
              
          }];
}

- (NSString*) updateObject: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params{
    return @"Baasbox is not support";
}

- (void) deleteObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID{
    BAAClient* client = [BAAClient sharedClient];
    [client deletePath:[NSString stringWithFormat:@"document/%@/%@", className, objId]
          parameters:nil
             success:^(id responseObject) {
                 
                 [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:@"delete object success" andCallbackID:cbID];
                 
             } failure:^(NSError *error) {
                 
                 [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
                 
             }];

}

- (BOOL) deleteObject: (NSString*) className withId: (NSString*) objId{
    return false;
}

// Asset

-(void) loadAssetJSON:(NSDictionary *)params{
    NSString* assetName = [params objectForKey:@"Param1"];
    long cbId = [[params objectForKey:@"Param2"] longValue];
    
    NSString* path = [NSString stringWithFormat:@"asset/%@/data",assetName];
    
    NSLog(@"loadAssetJSON with name: %@ cbid: %ld",assetName,cbId);
    
    BAAClient *client = [BAAClient sharedClient];
    [client getPath:path
         parameters:nil
            success:^(id responseObject) {
                NSDictionary *d = responseObject[@"data"];
                [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:d andCallbackID:cbId];
                NSLog(@"resp %@", responseObject);
            }
            failure:^(NSError *error) {
                NSLog(@"err %@", error);
                [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbId];
            }];
}




@end
