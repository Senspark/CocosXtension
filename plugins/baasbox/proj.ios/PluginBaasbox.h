//
//  PluginBaasbox.h
//  PluginBaasbox
//
//  Created by Tran Van Tuan on 12/21/15.
//  Copyright © 2015 Senspark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceBaaS.h"

@interface PluginBaasbox : NSObject<InterfaceBaaS>

// multiple params: NSDictionary, @Param1, @param2
// one params: int,long, double.. -> NSNumber

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
 @param1 :(NSString*) facebookPlayers
 @param2 :(long) callbackId
 */
-(void) fetchScoresFriendsFacebook:(NSDictionary*) params;


@end
