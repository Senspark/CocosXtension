//
//  DataWrapper.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/12/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#ifndef PluginProtocol_DataWrapper_h
#define PluginProtocol_DataWrapper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ProtocolData.h"

@interface DataWrapper : NSObject
{
    
}

+ (void) onDataResult:(id) obj withRet:(cocos2d::plugin::DataActionResultCode) ret withData: (NSData*) data;
+ (UIViewController *) getCurrentRootViewController;

@end

#endif
