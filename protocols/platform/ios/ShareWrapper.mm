/****************************************************************************
Copyright (c) 2012+2013 cocos2d+x.org

http://www.cocos2d+x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#import "ShareWrapper.h"
#include "PluginUtilsIOS.h"
#include "ProtocolShare.h"
#include "ParseUtils.h"

using namespace cocos2d::plugin;

@implementation ShareWrapper

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
/*+ (void) onShareResult:(id) obj withRet:(int) ret withContent: (NSDictionary*) content withMsg:(NSString*) msg
{
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolShare* pShare = dynamic_cast<ProtocolShare*>(pPlugin);
    if (pShare) {
        ProtocolShare::CallbackWrapper* wrapper = ();
        const char* chMsg = [msg UTF8String];
        if (callback)
        {
            std::string stdmsg(chMsg);
            callback(ret, [ParseUtils createMapFromDict:content], stdmsg);
        }else{
            PluginUtilsIOS::outputLog("Can't find the listener of plugin %s", pPlugin->getPluginName());
        }
    } else {
        PluginUtilsIOS::outputLog("Can't find the C++ object of the Share plugin");
    }
}*/

+ (void) onShareResult:(id) obj withRet:(int) ret withContent: (NSDictionary*) content withMsg:(NSString*) msg andCallbackID: (long) cbID {
    PluginProtocol* pPlugin = PluginUtilsIOS::getPluginPtr(obj);
    ProtocolShare* pShare = dynamic_cast<ProtocolShare*>(pPlugin);
    if (pShare && cbID) {
        ProtocolShare::CallbackWrapper* wrapper = (ProtocolShare::CallbackWrapper*) cbID;
        
        std::string stdmsg = msg ? [msg UTF8String] : "";
        
        wrapper->fnPtr(ret, [ParseUtils createMapFromDict:content], stdmsg);
        
        delete wrapper;
    } else {
        PluginUtilsIOS::outputLog("Can't find the C++ object of the Share plugin or listener.");
    }
}

#pragma GCC diagnostic pop

+ (UIViewController *)getCurrentRootViewController;
{
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
