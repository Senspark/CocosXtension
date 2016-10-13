//
//  SSAdMobUtility.m
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSAdMobUtility.h"

@implementation SSAdMobUtility

+ (UIViewController* _Nullable)getCurrentRootViewController {
    // [[[[UIApplication sharedApplication] delegate] window]
    // rootViewController];
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

@end
