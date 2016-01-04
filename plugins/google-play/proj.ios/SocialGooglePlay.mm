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

@interface GooglePlayControllerDelegate : NSObject <GPGLauncherDelegate>
{
    long _callbackID;
}

- (id) initWithCallbackID: (long) callbackID;
- (void)launcherDismissed;

@end

@implementation GooglePlayControllerDelegate

- (id) initWithCallbackID:(long)callbackID
{
    if (self = [super init]) {
        _callbackID = callbackID;
    }
    
    return self;
}

- (void)launcherDismissed {
    [SocialWrapper onDialogDismissedWithCallback:_callbackID];
    [self release];
}

@end

@implementation SocialGooglePlay

- (void) configDeveloperInfo : (NSDictionary*) cpInfo
{
}

- (void) submitScore: (NSString*) leaderboardID withScore: (int) score withCallback:(long) callbackID
{
    GPGScore *myScore = [[[GPGScore alloc] initWithLeaderboardId:leaderboardID] autorelease];
    myScore.value = score;
    [myScore submitScoreWithCompletionHandler:^(GPGScoreReport *report, NSError *error) {
        if (error) {
            NSLog(@"Submit score fail.");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Submit score fail." andCallback:callbackID];
        } else {
            NSLog(@"Submit score %d", score);
            
            if (![report isHighScoreForLocalPlayerAllTime]) {
                NSLog(@"%lld is a good score, but it's not enough to beat your all-time score of %@!",
                      report.reportedScoreValue,
                      report.highScoreForLocalPlayerAllTime.formattedScore);
            }
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Submit score successfully." andCallback:callbackID];
        }
    }];
}

- (void) showLeaderboards: (long) callbackID;
{
    GPGLauncherController* controller = [[[GPGLauncherController alloc] init] autorelease];
    
    controller.launcherDelegate = [[GooglePlayControllerDelegate alloc] initWithCallbackID:callbackID];
    [controller presentLeaderboardList];
}

- (void) showLeaderboard: (NSString*) leaderboardID withCallback:(long)callbackID
{
    GPGLauncherController* controller = [[[GPGLauncherController alloc] init] autorelease];
    
    controller.launcherDelegate = [[GooglePlayControllerDelegate alloc] initWithCallbackID:callbackID];
    
    [controller presentLeaderboardWithLeaderboardId:leaderboardID];
}

- (void) unlockAchievement: (NSMutableDictionary*) achInfo withCallback: (long)callbackID
{
    NSString* achievementId = [achInfo objectForKey:@"achievementId"];
    GPGAchievement* unlockMe = [GPGAchievement achievementWithId:achievementId];
    
    [unlockMe unlockAchievementWithCompletionHandler:^(BOOL newlyUnlocked, NSError *error) {
        if (error) {
            NSLog(@"Unlock achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Unlock achievement fail." andCallback:callbackID];
        } else {
            NSLog(@"Unlock achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Unlock achievement successfully." andCallback:callbackID];
        }
    }];
}

- (void) revealAchievement:(NSDictionary *)params
{
    NSDictionary* achInfo = [params objectForKey:@"Param1"];
    long cbID = [[params objectForKey:@"Param2"] longValue];
    
    NSString* achievementId = [achInfo objectForKey:@"achievementId"];

    GPGAchievement* revealMe = [GPGAchievement achievementWithId:achievementId];
    
    [revealMe revealAchievementWithCompletionHandler:^(GPGAchievementState state, NSError *error) {
        if (error) {
            NSLog(@"Reveal achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Reveal achievement fail." andCallback:cbID];
        } else {
            NSLog(@"Reveal achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Reveal achievement successfully." andCallback:cbID];
        }
    }];
}

- (void) resetAchievement:(NSDictionary *) params
{
    NSDictionary* achInfo = [params objectForKey:@"Param1"];
    long cbID = [[params objectForKey:@"Param2"] longValue];
    
    NSString* achievementId = [achInfo objectForKey:@"achievementId"];
    
    GPGAchievement* resetMe = [GPGAchievement achievementWithId:achievementId];
    
    [resetMe resetAchievementWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Reset achievement fail");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Reset achievement fail." andCallback:cbID];
        } else {
            NSLog(@"Reset achievement successfully.");
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Reset achievement successfully." andCallback:cbID];
        }
    }];
}

- (void) resetAchievements: (long) cbID
{
    [GPGAchievement resetAllAchievementsWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Reset achievements failed");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Reset achievement fail." andCallback:cbID];
        } else {
            NSLog(@"Reset achievements successfully.");
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Reset achievement successfully, login again to see chages." andCallback:cbID];
        }
    }];
}

- (void) showAchievements: (long) cbID
{
    GPGLauncherController* controller = [[[GPGLauncherController alloc] init] autorelease];
    controller.launcherDelegate = [[GooglePlayControllerDelegate alloc] initWithCallbackID:cbID];
    
    [controller presentAchievementList];
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
