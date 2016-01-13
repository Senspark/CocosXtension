//
//  UserGooglePlus.h
//  UserGooglePlus
//
//  Created by Nikel Arteta on 1/6/16.
//  Copyright © 2016 Senspark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceUser.h>

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface UserGooglePlus : NSObject <InterfaceUser> {
    NSString*   _clientID;
}

@property BOOL debug;

// ----- Interface of GooglePlayUser
- (NSString*) getUserID;
- (NSString*) getUserAvatarUrl;
- (NSString*) getUserDisplayName;


- (void) beginUserInitiatedSignIn;

// ---- Delegate ----
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;
- (void)didFinishGoogleAuthWithError:(NSError *)error;

@end