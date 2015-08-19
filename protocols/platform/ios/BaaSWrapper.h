//
//  BaaSWrapper.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/17/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaaSWrapper : NSObject
{
    
}


+ (void) onActionResult:(id) obj withRet:(int) ret andMsg:(NSString*) jsonMsg;

+ (UIViewController *) getCurrentRootViewController;

+ (NSString*) makeErrorJsonString: (NSError*) error;

@end
