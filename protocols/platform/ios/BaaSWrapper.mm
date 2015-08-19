//
//  BaaSWrapper.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 8/17/15.
//  Copyright (c) 2015 zhangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaaSWrapper.h"
#import "ProtocolBaaS.h"
#import "PluginUtilsIOS.h"

using namespace cocos2d::plugin;

@implementation BaaSWrapper

+ (void) onActionResult:(id) obj withRet:(int) ret andMsg:(NSString*) msg;
{
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
    if (pBaaS) {
        BaaSActionListener* listener = pBaaS->getActionListener();
        ProtocolBaaS::ProtocolBaaSCallback callback = pBaaS->getCallback();
        const char* chMsg = [msg UTF8String];
        if (NULL != listener)
        {
            listener->onActionResult(pBaaS, ret, chMsg);
        }else if(callback){
            std::string stdmsg = "";
            if (chMsg)
                stdmsg = chMsg;
                
            callback(ret, stdmsg);
        }else{
            PluginUtilsIOS::outputLog("Can't find the listener of plugin %s", pPlugin->getPluginName());
        }
    } else {
        PluginUtilsIOS::outputLog("Can't find the C++ object of the User plugin");
    }
}

+ (NSString*) makeErrorJsonString: (NSError*) error {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    NSUInteger code = error ? error.code : 0;
    NSString* desc = error ? error.description : @"";
    
    [dict setValue:[NSNumber numberWithUnsignedInteger:code] forKey:@"code"];
    [dict setValue:desc forKey:@"description"];
    
    NSError *writeJsonError = [[NSError alloc] init];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&writeJsonError];
    
    if (data)
        return [NSString stringWithUTF8String:(const char*)[data bytes]];
    
    return nil;
}

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
