//
//  UserGoogleSignIn.hpp
//  PluginGooglePlus
//
//  Created by Senspark-Dev5 on 9/8/17.
//  Copyright © 2017 Senspark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceUser.h>

@interface UserGoogleSignIn : NSObject <InterfaceUser> {

}

- (NSString*) getUserID;
- (NSString*) getUserAvatarUrl;
- (NSString*) getUserDisplayName;


@end
