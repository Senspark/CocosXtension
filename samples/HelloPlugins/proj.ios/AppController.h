#import <UIKit/UIKit.h>

#import <GooglePlus/GooglePlus.h>

@class RootViewController;

@interface AppController : NSObject <UIApplicationDelegate, GPPDeepLinkDelegate> {
    UIWindow *window;
    RootViewController    *viewController;
}

@end

