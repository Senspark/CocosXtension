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

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) submitScore: (NSString*) leaderboardID withScore: (long) score;
- (void) showLeaderboard: (NSString*) leaderboardID;
- (void) unlockAchievement: (NSMutableDictionary*) achInfo;
- (void) showAchievements;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;
- (void) resetAchievements;
- (void) showLeaderboards;

@end
