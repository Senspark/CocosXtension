//
//  BaaSBaasbox.h
//  BaaSBaasbox
//
//  Created by Tran Van Tuan on 12/21/15.
//  Copyright © 2015 Senspark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceBaaS.h"

@interface BaaSBaasbox : NSObject<InterfaceBaaS>



-(void) registerForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken completion:(void(^)(BOOL))successed;

-(void) fetchUserProfileWithCallbackId:(NSNumber*)cbId;

/**
 @param1 :(NSString*) facebookToken
 @param2 :(long) callbackId
 */
-(void) loginWithFacebookToken:(NSDictionary*) params;

/**
 @param1 :(NSString*) profile
 @param2 :(long) callbackId
 */
-(void) updateUserProfile:(NSDictionary*) params;

/**
 @param1 :(NSString*) condition
 @param2 :(long) callbackId
 */
-(void) loadUsersWithParameters:(NSDictionary*) params;


@end
