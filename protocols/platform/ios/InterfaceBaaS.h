//
//  InterfaceBaaS.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/13/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#ifndef PluginProtocol_InterfaceBaaS_h
#define PluginProtocol_InterfaceBaaS_h

#import <Foundation/Foundation.h>

@protocol InterfaceBaaS <NSObject>

- (void) configDeveloperInfo:(NSDictionary*) devInfo;
- (void) signUpWithParams: (NSDictionary*) params ;
- (void) loginWithUsername: (NSString*) username andPassword: (NSString*) password;
- (void) logout;
- (BOOL) isLoggedIn;

- (void) saveObjectInBackground: (NSString*) className withParams: (NSDictionary*) obj;
- (NSString*) saveObject: (NSString*) className withParams: (NSDictionary*) obj;

- (void) getObjectInBackground: (NSString*) className withId: (NSString*) objId;
- (NSDictionary*) getObject: (NSString*) className withId: (NSString*) objId;

- (void) updateObjectInBackground: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params;
- (NSString*) updateObject: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params;

- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end

#endif
