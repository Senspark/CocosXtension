/****************************************************************************
 Copyright (c) 2014 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
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

#import "ShareFacebook.h"
#import "ShareWrapper.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseUtils.h"
#include <string>

#define OUTPUT_LOG(...)     if (self.debug) NSLog(__VA_ARGS__);

@interface ShareFacebook() <FBSDKSharingDelegate, FBSDKGameRequestDialogDelegate>

@end

@implementation ShareFacebook

@synthesize debug = __debug;

- (id) init {
    if (self = [super init]) {
        _contentMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *key = [kv[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[key] = val;
    }
    return params;
}

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo {
}

- (void) share: (NSDictionary*) shareInfo withCallback:(long)cbID
{
    NSString *link = [shareInfo objectForKey:@"link"];
    NSString *photo = [shareInfo objectForKey:@"photo"];
    NSString *video = [shareInfo objectForKey:@"video"];
    
    if (link) {
        // Link type share info
        NSString *link = [shareInfo objectForKey:@"link"];
        NSString *caption = [shareInfo objectForKey:@"caption"];
        NSString *desc = [shareInfo objectForKey:@"description"];
        NSString *photo = [shareInfo objectForKey:@"picture"];
        
        FBSDKShareLinkContent* content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:link];
        content.contentTitle = caption;
        content.contentDescription = desc;
        content.imageURL = [NSURL URLWithString:photo];
        
        // If the Facebook app is installed and we can present the share dialog
        id dialog = [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];
        [_contentMap setObject:[NSNumber numberWithLong:cbID] forKey:dialog];

    }
    else if (photo) {
        NSURL *photoUrl = [NSURL URLWithString:[shareInfo objectForKey:@"photo"]];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoUrl]];
        
        FBSDKSharePhoto* sharePhoto = [[FBSDKSharePhoto alloc] init];
        sharePhoto.image = img;
        
        FBSDKSharePhotoContent* content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[sharePhoto];
        
        
        id dialog = [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];
        [_contentMap setObject:[NSNumber numberWithLong:cbID] forKey:dialog];
    }
    else if (video) {
        FBSDKShareVideo *shareVideo = [[FBSDKShareVideo alloc] init];
        shareVideo.videoURL = [NSURL URLWithString:video];
        
        FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
        content.video = shareVideo;
        
        id dialog = [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];
        [_contentMap setObject:[NSNumber numberWithLong:cbID] forKey:dialog];
    } else {
        NSString *msg = [ParseUtils MakeJsonStringWithObject:@"Share failed, share target absent or not supported, please add 'siteUrl' or 'imageUrl' in parameters" andKey:@"error_message"];
        [ShareWrapper onShareResult:self withRet:kShareFail withContent:shareInfo withMsg:msg andCallbackID:cbID];
    }
}

- (void) setDebugMode: (BOOL) debug
{
    self.debug = debug;
}

- (NSString*) getSDKVersion
{
    return [FBSDKSettings sdkVersion];
}

- (NSString*) getPluginVersion
{
    return @"0.9.0";
}

#pragma mark -
#pragma Facebook Sharing Delegate
/*!
@abstract Sent to the delegate when the share completes without error or cancellation.
@param sharer The FBSDKSharing that completed.
@param results The results from the sharer.  This may be nil or empty.
*/
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSNumber* numberCallback = [_contentMap objectForKey:sharer];
    
    long callbackID = 0;
    
    if (numberCallback) {
        callbackID = [numberCallback longValue];
        [_contentMap removeObjectForKey:sharer];
    }
    
    [ShareWrapper onShareResult:self withRet:kShareSuccess withContent:nil withMsg:[ParseUtils NSDictionaryToNSString:results] andCallbackID:callbackID];
}

/*!
@abstract Sent to the delegate when the sharer encounters an error.
@param sharer The FBSDKSharing that completed.
@param error The error.
*/
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSNumber* numberCallback = [_contentMap objectForKey:sharer];
    
    long callbackID = 0;
    
    if (numberCallback) {
        callbackID = [numberCallback longValue];
        [_contentMap removeObjectForKey:sharer];
    }
    
    [ShareWrapper onShareResult:self withRet:kShareFail withContent:nil withMsg:error.description andCallbackID:callbackID];

}

/*!
@abstract Sent to the delegate when the sharer is cancelled.
@param sharer The FBSDKSharing that completed.
*/
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSNumber* numberCallback = [_contentMap objectForKey:sharer];
    
    long callbackID = 0;
    
    if (numberCallback) {
        callbackID = [numberCallback longValue];
        [_contentMap removeObjectForKey:sharer];
    }
    
    [ShareWrapper onShareResult:self withRet:kShareCancel withContent:nil withMsg:@"User cancelled request" andCallbackID:callbackID];
}


#pragma mark - facebook invite
-(void) openInviteDialog:(NSDictionary*) params {
    NSDictionary *shareInfo = [params objectForKey:@"Param1"];
    long cbID               = [[params objectForKey:@"Param2"] longValue];
    
    NSString* recipients    = [shareInfo objectForKey:@"recipients"];
    NSString* title         = [shareInfo objectForKey:@"title"];
    NSString* message       = [shareInfo objectForKey:@"message"];
    
    FBSDKGameRequestDialog* gameRequestDialog   = [[FBSDKGameRequestDialog alloc] init];
    FBSDKGameRequestContent* content            = [[FBSDKGameRequestContent alloc] init];
    content.title                               = title;
    content.message                             = message;
    content.recipients                          = [recipients componentsSeparatedByString:@","];
    gameRequestDialog.content                   = content;
    gameRequestDialog.delegate                  = self;
    gameRequestDialog.frictionlessRequestsEnabled = YES;
    [gameRequestDialog setValue:[NSNumber numberWithLong:cbID] forKey:@"callbackID"];
    [gameRequestDialog show];
}

-(void) sendGameRequest:(NSDictionary*) params {
    NSDictionary *shareInfo = [params objectForKey:@"Param1"];
    NSNumber *cbID               = [params objectForKey:@"Param2"];
    
    NSString* recipients    = [shareInfo objectForKey:@"recipients"];
    NSString* title         = [shareInfo objectForKey:@"title"];
    NSString* message       = [shareInfo objectForKey:@"message"];
    
    int actionType          = FBSDKGameRequestActionTypeNone;
    if ([shareInfo objectForKey:@"action-type"])
        actionType = [[shareInfo objectForKey:@"action-type"] intValue];

    NSString* objectId      = [shareInfo objectForKey:@"object-id"];
    NSString* data          = [shareInfo objectForKey:@"data"];
    
    FBSDKGameRequestDialog* gameRequestDialog   = [[FBSDKGameRequestDialog alloc] init];
    FBSDKGameRequestContent* content            = [[FBSDKGameRequestContent alloc] init];
    
    content.objectID                            = objectId;
    content.title                               = title;
    content.message                             = message;
    content.recipients                          = [recipients componentsSeparatedByString:@","];
    content.data                                = data;
    content.actionType                          = (FBSDKGameRequestActionType) actionType;
    gameRequestDialog.content                   = content;
    gameRequestDialog.delegate                  = self;
    
    NSDictionary* tag = [NSDictionary dictionaryWithObjectsAndKeys: shareInfo, @"share-info", cbID, @"callback-id", nil];
    [_contentMap setObject:tag forKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    
    [gameRequestDialog show];
}

/**
 implement request method
 */
- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didCompleteWithResults:(NSDictionary*) results {
    NSLog(@"data content request dialog %@",gameRequestDialog.content.data);
    
    NSDictionary* tag = [_contentMap objectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    [_contentMap removeObjectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    
    NSNumber* numberID = [tag valueForKey:@"callback-id"];
    NSDictionary* content = [tag valueForKey:@"share-info"];
    
    if (numberID) {
        [ShareWrapper onShareResult:self withRet:kShareSuccess withContent:content withMsg:@"request success" andCallbackID:[numberID longValue]];
    }

}

- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didFailWithError:(NSError*) error {
    NSDictionary* tag = [_contentMap objectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    [_contentMap removeObjectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    
    NSNumber* numberID = [tag valueForKey:@"callback-id"];
    NSDictionary* content = [tag valueForKey:@"share-info"];
    
    if (numberID) {
        [ShareWrapper onShareResult:self withRet:kShareFail withContent:content withMsg:@"request failed" andCallbackID:[numberID longValue]];
    }
}

- (void) gameRequestDialogDidCancel:(FBSDKGameRequestDialog*) gameRequestDialog {
    NSDictionary* tag = [_contentMap objectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    [_contentMap removeObjectForKey:[NSNumber numberWithLong:(long)gameRequestDialog]];
    
    NSNumber* numberID = [tag valueForKey:@"callback-id"];
    NSDictionary* content = [tag valueForKey:@"share-info"];
    
    if (numberID) {
        [ShareWrapper onShareResult:self withRet:kShareCancel withContent:content withMsg:@"request cancel" andCallbackID:[numberID longValue]];
    }
}

@end