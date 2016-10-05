//
//  ProtocolPlatform.m
//  PluginProtocol
//
//  Created by Duc Nguyen on 1/5/16.
//  Copyright © 2016 zhangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EReachability.h"

#include "ProtocolPlatform.h"

static EReachability* _reachability = nullptr;

USING_NS_CC_PLUGIN;

ProtocolPlatform::ProtocolPlatform() {
    _reachability = [[EReachability reachabilityWithHostName:@"www.google.com"] retain];
    _reachability.reachableBlock = ^void(EReachability * reachability) {
        if (_callback) {
            _callback(PlatformResultCode::kConnected, "");
        }
    };
    
    _reachability.unreachableBlock = ^void(EReachability * reachability) {
        if (_callback) {
            _callback(PlatformResultCode::kUnconnected, "");
        }
    };
    
    [_reachability startNotifier];
}

ProtocolPlatform::~ProtocolPlatform() {
    [_reachability release];
}

bool ProtocolPlatform::isRelease() {
    NSLog(@"ProtocolPlatform does not support isRelease on iOS");
    return false;
}

float ProtocolPlatform::getMainScreenScale() {
    float scale = 1.0f;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }
    
    return scale;
}

std::string ProtocolPlatform::getCurrentLanguageCode() {
    static char code[3]={0};
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    // get the current language code.(such as English is "en", Chinese is "zh" and so on)
    NSDictionary* temp = [NSLocale componentsFromLocaleIdentifier:currentLanguage];
    NSString * languageCode = [temp objectForKey:NSLocaleLanguageCode];
    [languageCode getCString:code maxLength:3 encoding:NSASCIIStringEncoding];
    code[2]='\0';
    return code;
}

void ProtocolPlatform::openApplication(const std::string &appName) {
    NSString* nsAppName = [NSString stringWithFormat:@"%s://", appName.c_str()];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsAppName]];
}

bool ProtocolPlatform::isAppInstalled(const std::string& url) {
    NSString* appName = [NSString stringWithFormat:@"%s://", url.c_str()];
    bool isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appName]];
    return isInstalled;
}

bool ProtocolPlatform::isConnected(const std::string& hostName) {
    EReachability *reachability = [EReachability reachabilityWithHostName:[NSString stringWithUTF8String:hostName.c_str()]];
    
    return [reachability isReachable];
}

std::string ProtocolPlatform::getSHA1CertFingerprint() {
    NSLog(@"ProtocolPlatform does not support getSHA1CertFingerprint on iOS");
    return "";
}

std::string ProtocolPlatform::getVersionCode() {
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    return [versionString UTF8String];
}

std::string ProtocolPlatform::getVersionName() {
    NSString *versionName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    return [versionName UTF8String];
}

void ProtocolPlatform::sendFeedback(const std::string &appName) {
    char rep[100];
    sprintf(rep, "mailto:feedback@senspark.com?subject=Feedbacks on %s", appName.c_str());
    NSString *recipients = [[NSString alloc] initWithUTF8String:rep];
    
    char abody[1000];
    sprintf(abody, "&body=I have feedbacks on %s:\n1.\n2.\n3.\n\nI accept to send the following information to developers for improving the app.\n", appName.c_str());
    NSString *body = [[NSString alloc] initWithUTF8String:abody];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

bool ProtocolPlatform::isTablet() {
    if ( [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        return true; /* Device is iPad */
    } else {
        return false;
    }
}

void ProtocolPlatform::finishActivity() {
    NSLog(@"Not support on iOS");
}
