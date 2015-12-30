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

@interface GameCenterControllerDelegate: NSObject <GKGameCenterControllerDelegate>
{
    long _callbackID;
}

- (id) initWithCallbackID: (long) callbackID;

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController;

@end

@implementation GameCenterControllerDelegate

- (id) initWithCallbackID: (long) callbackID {
    if (self = [self init]) {
        _callbackID = callbackID;
    }
    
    return self;
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        [SocialWrapper onDialogDismissedWithCallback:_callbackID];
        [self release];
    }];
}

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

- (void) configDeveloperInfo : (NSDictionary*) cpInfo {
    
}

- (void) submitScore: (NSString*) leaderboardID withScore: (int) score withCallback:(long)callbackID
{
    GKScore *myScore = [[[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID] autorelease];
    myScore.value = score;
    
    [GKScore reportScores:@[myScore] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Submit score fail.");
            
            [SocialWrapper onSocialResult:self withRet:false withMsg:@"Submit score fail." andCallback:callbackID];
        } else {
            NSLog(@"Submit score %d", score);
            
            [SocialWrapper onSocialResult:self withRet:true withMsg:@"Submit score successfully." andCallback:callbackID];
        }
    }];
}

- (void) showLeaderboard: (NSString*) leaderboardID withCallback:(long)callbackID
{
    GKGameCenterViewController *viewController = [[[GKGameCenterViewController alloc] init] autorelease];
    
    viewController.leaderboardIdentifier = leaderboardID;
    viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    
    viewController.gameCenterDelegate = [[GameCenterControllerDelegate alloc] initWithCallbackID:callbackID];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[SocialWrapper getCurrentRootViewController] presentViewController:viewController animated:YES completion:nil];
    });
}

- (void) showLeaderboards: (long) cbID
{
    [self showLeaderboard: nil withCallback:cbID];
}

- (void) unlockAchievement: (NSDictionary*) achInfo withCallback:(long)callbackID
{
    NSString* achievementId = [achInfo objectForKey:@"achievementId"];
    double percentComplete = [(NSNumber*) [achInfo objectForKey:@"percent"] doubleValue];
    
    [self submitAchievement:achievementId percentComplete:percentComplete andCallback:callbackID];
}

- (void) showAchievements: (long) cbID
{
    GKGameCenterViewController *viewController = [[[GKGameCenterViewController alloc] init] autorelease];
    viewController.viewState = GKGameCenterViewControllerStateAchievements;

    viewController.gameCenterDelegate = [[GameCenterControllerDelegate alloc] initWithCallbackID: cbID];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SocialWrapper getCurrentRootViewController] presentViewController:viewController animated:YES completion:nil];
    });
}

- (void) resetAchievements: (long) cbID
{
    self.earnedAchievementCache= NULL;
    [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SocialWrapper onSocialResult:self withRet:false withMsg:@"Reset achievements fail." andCallback:cbID];
            } else {
                [SocialWrapper onSocialResult:self withRet:true withMsg:@"Reset achievements success." andCallback:cbID];
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

- (void) submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete  andCallback:(long) cbID
{

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
                
                [self submitAchievement: identifier percentComplete: percentComplete andCallback:cbID];
            }
            else {
                //Something broke loading the achievement list.  Error out, and we'll try again the next time achievements submit.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SocialWrapper onSocialResult:self withRet:false withMsg:@"Error when loading the achievement list, please try again later." andCallback:cbID];

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
                
                [SocialWrapper onSocialResult:self withRet:false withMsg:[NSString stringWithFormat:@"The achievement has been unlocked - %@", identifier] andCallback:cbID];
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
                        [SocialWrapper onSocialResult:self withRet:false withMsg:[NSString stringWithFormat:@"Submit achievement with id: %@ error", identifier] andCallback:cbID];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SocialWrapper onSocialResult:self withRet:true withMsg:[NSString stringWithFormat:@"Submit achievement with id: %@ success", identifier] andCallback:cbID];
                        
                    });
                }
            }];
        }
    }
}

@end
