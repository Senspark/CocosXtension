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

-(void) loginWithFacebookToken:(NSString*)facebookToken andCallbackId:(int)cbId;
-(void) updateProfileUser:(NSString*)jsonData withCallbackId:(int)cbId;
-(void) fetchProfileUserWithCallbackId:(int)cbId;

@end
