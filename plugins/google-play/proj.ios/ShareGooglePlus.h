//
//  ShareGooglePlus.h
//  PluginGooglePlay
//
//  Created by Nikel Arteta on 12/2/15.
//  Copyright © 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef ShareGooglePlus_h
#define ShareGooglePlus_h

#import <Foundation/Foundation.h>
#import <InterfaceShare.h>

@interface ShareGooglePlus : NSObject <InterfaceShare> {

}

@property BOOL debug;
@property (copy, nonatomic) NSMutableDictionary* mShareInfo;

/**
 * @brief interfaces of protocol : InterfaceShare
 */
- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo;
//- (void) shareToGooglePlus:(int32_t)level withScore:(int64_t)score withURLToShare:(NSString *)urlToShare withPreFillText:(NSString *)prefillText withContentDeepLinkId:(NSString *)contentDeepLinkId andDeepLinkId:(NSString *)deepLinkId;


- (void) setDebugMode: (BOOL) debug;

- (NSString*) getSDKVersion;
- (NSString*) getPluginVersion;

@end

@interface ShareGooglePlusDelegate : NSObject  {}

@property (assign) long callbackID;

- (id) initWithCallbackID: (long) cbID;

// ---- Delegate ----
- (void)finishedSharingWithError:(NSError *)error;
- (void)didReceiveDeepLink: (GPPDeepLink *)deepLink;

@end

#endif /* ShareGooglePlus_h */
