//
//  SocialGooglePlay.h
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceSocial.h>

@interface SocialGooglePlay : NSObject<InterfaceSocial>
{
}

@property BOOL  debug;

//------interface social -------

- (void) revealAchievement: (NSDictionary*) achInfo;

- (void) resetAchievement: (NSDictionary*) achiInfo;

@end
