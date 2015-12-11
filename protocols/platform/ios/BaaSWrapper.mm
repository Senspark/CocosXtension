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
#import "ParseUtils.h"

using namespace cocos2d::plugin;

@implementation BaaSWrapper

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

+ (void) onBaaSActionResult: (id)obj withReturnCode: (int)ret andReturnMsg: (NSString*) msg andCallbackID: (long) callbackID {
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
    if (pBaaS && callbackID) {

        ProtocolBaaS::CallbackWrapper* wrapper = (ProtocolBaaS::CallbackWrapper*) callbackID;
        
        std::string stdmsg = [msg UTF8String] ? [msg UTF8String] : "";
        
        wrapper->fnPtr(ret, stdmsg);
        delete wrapper;

    }
}

+ (void) onBaaSActionResult:(id)obj withReturnCode:(int)ret andReturnObj:(id)returnObj andCallbackID:(long)callbackID {
    
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolBaaS* pBaaS = dynamic_cast<ProtocolBaaS*>(pPlugin);
    if (pBaaS && callbackID) {
        ProtocolBaaS::CallbackWrapper* wrapper = (ProtocolBaaS::CallbackWrapper*) callbackID;
        
        NSString* msg = nil;
        
        if (returnObj != nil) {
            if ([returnObj isKindOfClass:[NSDictionary class]]) {
                msg = [ParseUtils NSDictionaryToNSString:returnObj];
            } else if ([returnObj isKindOfClass:[NSArray class]]) {
                msg = [ParseUtils NSArrayToNSString:returnObj];
            }
        }
        
        std::string stdmsg = [msg UTF8String] ? [msg UTF8String] : "";
        
        wrapper->fnPtr(ret, stdmsg);
        delete wrapper;
    }
    
}

#pragma GCC diagnostic pop

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
