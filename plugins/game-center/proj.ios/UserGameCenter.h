//
//  UserGameCenter.h
//  PluginGameCenter
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceUser.h>

@interface UserGameCenter : NSObject <InterfaceUser> {
    
}

@property BOOL debug;

// ----- Interface User ------
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) login;
- (void) logout;
- (BOOL) isLoggedIn;
- (NSString*) getSessionID;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end
