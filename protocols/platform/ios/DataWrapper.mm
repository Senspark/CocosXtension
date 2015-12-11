//
//  DataWrapper.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/12/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#include "DataWrapper.h"
#include "PluginUtilsIOS.h"


using namespace cocos2d::plugin;

@implementation DataWrapper

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (void) onDataResult:(id)obj withRet:(DataActionResultCode)ret withData:(NSData*) data {
    
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolData* pData = dynamic_cast<ProtocolData*>(pPlugin);
    if (pData) {
        DataActionListener* listener = pData->getActionListener();
        ProtocolData::ProtocolDataCallback callback = pData->getCallback();

        if (NULL != listener) {
            listener->onDataActionResult(pData, (DataActionResultCode) ret, (void*) data.bytes, data.length);
        }else if(callback){
            callback(ret, (void*) data.bytes, data.length);
        }else{
            PluginUtilsIOS::outputLog("Can't find the listener of plugin %s", pPlugin->getPluginName());
        }
    } else {
        PluginUtilsIOS::outputLog("Can't find the C++ object of the Data plugin");
    }
}
#pragma GCC diagnostic pop


+ (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result = nil;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
        else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
            result = topWindow.rootViewController;
            else
                NSAssert(NO, @"Could not find a root view controller.");
                
                return result;
}

@end