//
//  SocialGooglePlay.m
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 7/27/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <gpg/GooglePlayGames.h>
#import "SocialGooglePlay.h"
#import "SocialWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@implementation SocialGooglePlay

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo {
}

- (void) submitScore: (NSString*) leaderboardID withScore: (long) score
{
    GPGScore *myScore = [[GPGScore alloc] initWithLeaderboardId:leaderboardID];
    myScore.value = score;
    [myScore submitScoreWithCompletionHandler:^(GPGScoreReport *report, NSError *error) {
        if (error) {
            NSLog(@"Submit score fail.");
            
            [SocialWrapper onSocialResult:self withRet:kSubmitScoreFailed withMsg:@"Submit score fail."];
        } else {
            NSLog(@"Submit score %ld", score);
            
            if (![report isHighScoreForLocalPlayerAllTime]) {
                NSLog(@"%lld is a good score, but it's not enough to beat your all-time score of %@!",
                      report.reportedScoreValue,
                      report.highScoreForLocalPlayerAllTime.formattedScore);
            }
            
            [SocialWrapper onSocialResult:self withRet:kSubmitScoreSuccess withMsg:@"Submit score successfully."];
        }
    }];
}

- (void) showLeaderboards
{
    [[GPGLauncherController sharedInstance] presentLeaderboardList];
}

- (void) showLeaderboard: (NSString*) leaderboardID
{
    [[GPGLauncherController sharedInstance] presentLeaderboardWithLeaderboardId:leaderboardID];
}

- (void) unlockAchievement: (NSMutableDictionary*) achInfo
{
    NSString* achievementId = [achInfo objectForKey:@"achievemetId"];
    GPGAchievement* unlockMe = [GPGAchievement achievementWithId:achievementId];
    
    [unlockMe unlockAchievementWithCompletionHandler:^(BOOL newlyUnlocked, NSError *error) {
        if (error) {
            NSLog(@"Unlock achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:kUnlockAchiFailed withMsg:@"Unlock achievement fail."];
        } else {
            NSLog(@"Unlock achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:kUnlockAchiSuccess withMsg:@"Unlock achievement successfully."];
        }
    }];
}

- (void) revealAchievement:(NSMutableDictionary *)achInfo
{
    NSString* achievementId = [achInfo objectForKey:@"achievemetId"];
    GPGAchievement* revealMe = [GPGAchievement achievementWithId:achievementId];
    
    [revealMe revealAchievementWithCompletionHandler:^(GPGAchievementState state, NSError *error) {
        if (error) {
            NSLog(@"Reveal achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:kRevealAchiFailed withMsg:@"Reveal achievement fail."];
        } else {
            NSLog(@"Reveal achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:kRevealAchiSuccess withMsg:@"Reveal achievement successfully."];
        }
    }];
}

- (void) resetAchievement:(NSMutableDictionary *)achInfo
{
    NSString* achievementId = [achInfo objectForKey:@"achievemetId"];
    GPGAchievement* resetMe = [GPGAchievement achievementWithId:achievementId];
    
    [resetMe resetAchievementWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Reset achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:kRevealAchiFailed withMsg:@"Reset achievement fail."];
        } else {
            NSLog(@"Reset achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:kResetAchiSuccess withMsg:@"Reset achievement successfully."];
        }
    }];
}

- (void) resetAchievements
{
    [GPGAchievement resetAllAchievementsWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Reset achievements failed");
            
            [SocialWrapper onSocialResult:self withRet:kResetAchiFailed withMsg:@"Reset achievement fail."];
        } else {
            NSLog(@"Reset achievements successfully.");
            
            [SocialWrapper onSocialResult:self withRet:kResetAchiSuccess withMsg:@"Reset achievement successfully, login again to see chages."];
        }
    }];
}

- (void) showAchievements
{
    [[GPGLauncherController sharedInstance] presentAchievementList];
}

- (void) setDebugMode: (BOOL) debug
{
    _debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"1.4.1";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

@end
