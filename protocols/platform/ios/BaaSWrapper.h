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

+ (void) onBaaSActionResult: (id)obj withReturnCode: (int)ret andReturnMsg: (NSString*) msg andCallbackID: (long) callbackID;

+ (void) onBaaSActionResult: (id)obj withReturnCode: (int)ret andReturnObj: (id) returnObj andCallbackID: (long) callbackID;

+ (UIViewController *) getCurrentRootViewController;

+ (NSString*) makeErrorJsonString: (NSError*) error;

@end
