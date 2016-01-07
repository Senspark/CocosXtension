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

- (void) signUpWithParams: (NSDictionary*) params andCallbackID: (long) cbID;
- (void) loginWithUsername: (NSString*) username andPassword: (NSString*) password andCallbackID: (long) cbID;
- (void) logout: (long) cbID;
- (BOOL) isLoggedIn;
- (NSString*) getUserID;

- (void) saveObjectInBackground: (NSString*) className withParams: (NSDictionary*) obj andCallbackID:(long) cbID;
- (NSString*) saveObject: (NSString*) className withParams: (NSDictionary*) obj;

- (void) getObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID;
- (void) getObjectsInBackground: (NSString*) className withIds: (NSArray*) objIds andCallbackID:(long) cbID;

- (NSDictionary*) getObject: (NSString*) className withId: (NSString*) objId;

- (void) findObjectInBackground: (NSString*) className whereKey: (NSString*) key equalTo: (NSString*) value    withCallbackID: (long) callbackId;
- (void) findObjectsInBackground: (NSString*) className whereKey: (NSString*) key containedIn: (NSArray*) values    withCallbackID: (long) callbackId;

- (void) updateObjectInBackground: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params andCallbackID:(long) cbID;
- (NSString*) updateObject: (NSString*) className withId: (NSString*) objId withParams: (NSDictionary*) params;

- (void) deleteObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID;
- (BOOL) deleteObject: (NSString*) className withId: (NSString*) objId;


@end

#endif
