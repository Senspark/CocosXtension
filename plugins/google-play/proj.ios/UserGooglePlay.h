//
//  UserGooglePlay.h
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginGooglePlay_UserGooglePlay_h
#define PluginGooglePlay_UserGooglePlay_h

#import <Foundation/Foundation.h>
#import <InterfaceUser.h>


@interface UserGooglePlay : NSObject <InterfaceUser> {
    NSString*   _clientID;
}

@property BOOL debug;

// ----- Interface of GooglePlayUser
- (NSString*) getUserID;
- (NSString*) getUserAvatarUrl;
- (NSString*) getUserDisplayName;


- (void) beginUserInitiatedSignIn;

@end

#endif
