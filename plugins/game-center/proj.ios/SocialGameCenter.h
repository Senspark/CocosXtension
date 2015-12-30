//
//  SocialGameCenter.h
//  PluginGameCenter
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceSocial.h>

@class GKLeaderboard, GKAchievement, GKPlayer;

@interface SocialGameCenter : NSObject<InterfaceSocial>
{
}

@property BOOL debug;
@property (retain) NSMutableDictionary* earnedAchievementCache;

- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete andCallback: (long) cbID;

- (void) resetAchievements: (long) cbID;

@end
