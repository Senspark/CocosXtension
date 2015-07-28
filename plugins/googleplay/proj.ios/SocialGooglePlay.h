//
//  SocialGooglePlay.h
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <InterfaceSocial.h>

@interface SocialGooglePlay : NSObject
{
    
}

@property BOOL  debug;

//------interface social -------
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
- (void) submitScore: (NSString*) leaderboardID withScore: (long) score;
- (void) showLeaderboard: (NSString*) leaderboardID;
- (void) unlockAchievement: (NSMutableDictionary*) achInfo;
- (void) showAchievements;
- (void) setDebugMode: (BOOL) debug;
- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end
