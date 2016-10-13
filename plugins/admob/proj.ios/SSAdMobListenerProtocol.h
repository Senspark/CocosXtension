//
//  SSAdMobListenerProtocol.hpp
//  PluginAdmob
//
//  Created by Zinge on 10/13/16.
//  Copyright © 2016 cocos2d-x. All rights reserved.
//

@interface SSAdMobListenerProtocol : NSObject

- (id _Nullable)initWithAdsInterface:(id _Nonnull)interface;

@property (nonatomic, readonly, nonnull) id interface;

- (void)onResult:(int)code message:(NSString* _Nullable)message;

@end
