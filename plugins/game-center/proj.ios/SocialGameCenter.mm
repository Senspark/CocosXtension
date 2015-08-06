//
//  SocialGameCenter.m
//  PluginGameCenter
//
//  Created by Duc Nguyen on 7/31/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "SocialGameCenter.h"
#import "SocialWrapper.h"

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@interface SocialGameCenter() <GKGameCenterControllerDelegate, GKGameCenterControllerDelegate>

@end

@implementation SocialGameCenter

@synthesize earnedAchievementCache = _earnedAchievementCache;

- (id) init
{
    if (self = [super init])  {
        _earnedAchievementCache = nil;
    }
    
    return self;
}

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo {
    
}

- (void) submitScore: (NSString*) leaderboardID withScore: (long) score
{
    GKScore *myScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    myScore.value = score;
    
    [GKScore reportScores:@[myScore] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Submit score fail.");
            
            [SocialWrapper onSocialResult:self withRet:kSubmitScoreFailed withMsg:@"Submit score fail."];
        } else {
            NSLog(@"Submit score %ld", score);
            
            [SocialWrapper onSocialResult:self withRet:kSubmitScoreSuccess withMsg:@"Submit score successfully."];
        }
    }];
}

- (void) showLeaderboard: (NSString*) leaderboardID
{
    GKGameCenterViewController *viewController = [[GKGameCenterViewController alloc] init];
    viewController.leaderboardIdentifier = leaderboardID;
    viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    viewController.gameCenterDelegate = self;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[SocialWrapper getCurrentRootViewController] presentViewController:viewController animated:YES completion:nil];
    });
}

- (void) showLeaderboards
{
    [self showLeaderboard: nil];
}

- (void) unlockAchievement: (NSMutableDictionary*) achInfo
{
    NSString* achievementId = [achInfo objectForKey:@"achievementId"];
//    double percentComplete = [(NSNumber*) [achInfo objectForKey:@"percentComplete"] doubleValue];
    
    [self submitAchievement:achievementId percentComplete:100];
}

- (void) showAchievements
{
    GKGameCenterViewController *viewController = [[GKGameCenterViewController alloc] init];
    viewController.viewState = GKGameCenterViewControllerStateAchievements;
    viewController.gameCenterDelegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SocialWrapper getCurrentRootViewController] presentViewController:viewController animated:YES completion:nil];
    });
}

- (void) resetAchievements
{
    self.earnedAchievementCache= NULL;
    [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SocialWrapper onSocialResult:self withRet:kResetAchiFailed withMsg:@"Reset achievements fail."];
            } else {
                [SocialWrapper onSocialResult:self withRet:kResetAchiSuccess withMsg:@"Reset achievements success."];
            }
            
        });
     }];
}

- (void) setDebugMode: (BOOL) debug
{
    _debug = debug;
}

- (NSString*) getSDKVersion
{
    return @"8";
}

- (NSString*) getPluginVersion
{
    return @"0.1.0";
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [[SocialWrapper getCurrentRootViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void) submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete {

    //GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report
    // new achievements to the user, then you need to check if it's been earned
    // before you submit.  Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
    // and reportAchievementWithCompletionHandler.  To avoid this, we fetch the current achievement list once,
    // then cache it and keep it updated with any new achievements.
    if(self.earnedAchievementCache == nil) {
        [GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if(error == nil) {
                NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [scores count]];
                for (GKAchievement* score in scores) {
                    [tempCache setObject: score forKey: score.identifier];
                }
                self.earnedAchievementCache= tempCache;
                
                [self submitAchievement: identifier percentComplete: percentComplete];
            }
            else {
                //Something broke loading the achievement list.  Error out, and we'll try again the next time achievements submit.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SocialWrapper onSocialResult:self withRet:kUnlockAchiFailed withMsg:@"Error when loading the achievement list, please try again later."];

                });
            }
            
        }];
    }
    else {
        //Search the list for the ID we're using...
        GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
        if(achievement != nil)  {
            if((achievement.percentComplete >= 100.0f) || (achievement.percentComplete >= percentComplete)) {
                //Achievement has already been earned so we're done.
                achievement = nil;
            }
            achievement.percentComplete = percentComplete;
        }
        else {
            achievement= [[GKAchievement alloc] initWithIdentifier: identifier];
            achievement.percentComplete = percentComplete;
            //Add achievement to achievement cache...
            [self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
        }
        achievement.showsCompletionBanner = YES;
        if(achievement != nil) {
            //Submit the Achievement...
            [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SocialWrapper onSocialResult:self withRet:kUnlockAchiFailed withMsg:[NSString stringWithFormat:@"Submit achievement with id: %@ error", identifier]];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SocialWrapper onSocialResult:self withRet:kUnlockAchiSuccess withMsg:[NSString stringWithFormat:@"Submit achievement with id: %@ success", identifier]];
                        
                    });
                }
            }];
        }
    }
}

@end
