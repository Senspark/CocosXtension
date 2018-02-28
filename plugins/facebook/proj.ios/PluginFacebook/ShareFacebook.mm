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

@interface FacebookSharingDelegate : NSObject <FBSDKSharingDelegate, FBSDKGameRequestDialogDelegate>
{
    long _callbackID;
}

@property (nonatomic, retain) ShareFacebook* sharer;
@property (nonatomic, retain) NSDictionary* shareInfo;

- (id) initWithSharer: (id) sharer andCallbackID:(long)callbackID;

@end

@implementation FacebookSharingDelegate

@synthesize sharer      = _sharer;
@synthesize shareInfo   = _shareInfo;

- (id) initWithSharer: (id) sharer andCallbackID:(long)callbackID
{
    if (self = [super init]) {
        self.sharer = sharer;
        _callbackID = callbackID;
    }
    
    NSLog(@"Facebook SDK version: %@", [FBSDKSettings sdkVersion]);
    
    return self;
}

- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didCompleteWithResults:(NSDictionary*) results {
    
    [ShareWrapper onShareResult:_sharer withRet:kShareSuccess withContent:_shareInfo withMsg:@"request success" andCallbackID:_callbackID];
    
    [self release];
    
}

- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didFailWithError:(NSError*) error {
    
    [ShareWrapper onShareResult:_sharer withRet:kShareFail withContent:_shareInfo withMsg:@"request failed" andCallbackID:_callbackID];
    
    [self release];
}

- (void) gameRequestDialogDidCancel:(FBSDKGameRequestDialog*) gameRequestDialog {
    [ShareWrapper onShareResult:_sharer withRet:kShareCancel withContent:_shareInfo withMsg:@"request cancel" andCallbackID:_callbackID];
    
    [self release];
}

- (void) dealloc {
    [_shareInfo release];
    [super dealloc];
}

#pragma mark -
#pragma Facebook Sharing Delegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
    [ShareWrapper onShareResult:_sharer withRet:kShareSuccess withContent:nil withMsg:[ParseUtils NSDictionaryToNSString:results] andCallbackID:_callbackID];
    
    [self release];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
    [ShareWrapper onShareResult:_sharer withRet:kShareFail withContent:nil withMsg:error.description andCallbackID:_callbackID];
    
    [self release];
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
    [ShareWrapper onShareResult:_sharer withRet:kShareCancel withContent:nil withMsg:@"User cancelled request" andCallbackID:_callbackID];
    
    [self release];
}

@end

@implementation ShareFacebook

@synthesize debug = __debug;

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *key = [kv[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[key] = val;
    }
    return params;
}

- (void) configDeveloperInfo : (NSDictionary*) cpInfo {
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
        
        NSURL *imageURL = [NSURL URLWithString:photo];
        NSURL *contentURL = [NSURL URLWithString:link];
        
        FBSDKShareLinkContent* content = [[[FBSDKShareLinkContent alloc] init] autorelease];
        [content setContentURL:contentURL];
//        [content setImageURL:imageURL];
//        [content setContentTitle:caption];
//        [content setContentDescription:desc];

        // If the Facebook app is installed and we can present the share dialog
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:[[FacebookSharingDelegate alloc] initWithSharer:self andCallbackID:cbID]];
    }
    else if (photo) {
        NSURL *photoUrl = [NSURL URLWithString:[shareInfo objectForKey:@"photo"]];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoUrl]];
        
        FBSDKSharePhoto* sharePhoto = [[[FBSDKSharePhoto alloc] init] autorelease];
        sharePhoto.image = img;
        
        FBSDKSharePhotoContent* content = [[[FBSDKSharePhotoContent alloc] init] autorelease];
        
        content.photos = @[sharePhoto];
        
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:[[FacebookSharingDelegate alloc] initWithSharer:self andCallbackID:cbID]];
    }
    else if (video) {
        FBSDKShareVideo *shareVideo = [[[FBSDKShareVideo alloc] init] autorelease];
        shareVideo.videoURL = [NSURL URLWithString:video];
        
        FBSDKShareVideoContent *content = [[[FBSDKShareVideoContent alloc] init] autorelease];
        content.video = shareVideo;
        
        
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:[[FacebookSharingDelegate alloc] initWithSharer:self andCallbackID:cbID]];
    } else {
        NSString *msg = [ParseUtils MakeJsonStringWithObject:@"Share failed, share target absent or not supported, please add 'siteUrl' or 'imageUrl' in parameters" andKey:@"error_message"];
        [ShareWrapper onShareResult:self withRet:kShareFail withContent:shareInfo withMsg:msg andCallbackID:cbID];
    }
}

- (void) likeFanpage:(NSString *)fanpageID {
    NSString* urlToLikeFor = [NSString stringWithFormat:@"https://www.facebook.com/%@", fanpageID];
    
    
    UIAlertView *message = [[[UIAlertView alloc] initWithTitle:@"Facebook Like"
                                                      message:@"Like us and never miss out on awesome events!"
                                                     delegate:nil
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil] autorelease];
    
    UIView* view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)] autorelease];
    
    FBSDKLikeControl* button = [[[FBSDKLikeControl alloc] initWithFrame:CGRectMake(0, 0, 200, 150)] autorelease];
    [button setObjectType:FBSDKLikeObjectTypePage];
    [button setObjectID:urlToLikeFor];
    [button setLikeControlAuxiliaryPosition:FBSDKLikeControlAuxiliaryPositionBottom];
    [button setLikeControlHorizontalAlignment:FBSDKLikeControlHorizontalAlignmentCenter];
    [button setLikeControlStyle:FBSDKLikeControlStyleStandard];
    [button setSoundEnabled:YES];
    [button setFrame:CGRectMake(button.frame.size.width/6 + 5, 0, 200, 150)];
    
    [view addSubview:button];
    
    [message setValue:view forKey:@"accessoryView"];
    [message show];
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

#pragma mark - facebook invite
-(void) openInviteDialog:(NSDictionary*) params {
    NSDictionary *shareInfo = [params objectForKey:@"Param1"];
    long cbID               = [[params objectForKey:@"Param2"] longValue];
    
    NSString* recipients    = [shareInfo objectForKey:@"recipients"];
    NSString* title         = [shareInfo objectForKey:@"title"];
    NSString* message       = [shareInfo objectForKey:@"message"];
    
    FBSDKGameRequestDialog* gameRequestDialog   = [[[FBSDKGameRequestDialog alloc] init] autorelease];
    FBSDKGameRequestContent* content            = [[[FBSDKGameRequestContent alloc] init] autorelease];
    content.title                               = title;
    content.message                             = message;
    content.recipients                          = [recipients componentsSeparatedByString:@","];
    gameRequestDialog.content                   = content;
    gameRequestDialog.delegate                  = [[FacebookSharingDelegate alloc] initWithSharer:self andCallbackID:cbID];
    gameRequestDialog.frictionlessRequestsEnabled = YES;
    [gameRequestDialog setValue:[NSNumber numberWithLong:cbID] forKey:@"callbackID"];
    [gameRequestDialog show];
}

-(void) sendGameRequest:(NSDictionary*) params {
    NSDictionary *shareInfo = [params objectForKey:@"Param1"];
    NSNumber *cbID          = [params objectForKey:@"Param2"];
    
    NSString* recipients    = [shareInfo objectForKey:@"recipients"];
    NSString* title         = [shareInfo objectForKey:@"title"];
    NSString* message       = [shareInfo objectForKey:@"message"];
    
    int actionType          = FBSDKGameRequestActionTypeNone;
    if ([shareInfo objectForKey:@"action-type"])
        actionType = [[shareInfo objectForKey:@"action-type"] intValue];

    NSString* objectId      = [shareInfo objectForKey:@"object-id"];
    NSString* data          = [shareInfo objectForKey:@"data"];
    
    FBSDKGameRequestDialog* gameRequestDialog   = [[[FBSDKGameRequestDialog alloc] init] autorelease];
    FBSDKGameRequestContent* content            = [[[FBSDKGameRequestContent alloc] init] autorelease];
    
    content.objectID                            = objectId;
    content.title                               = title;
    content.message                             = message;
    content.recipients                          = [recipients componentsSeparatedByString:@","];
    content.data                                = data;
    content.actionType                          = (FBSDKGameRequestActionType) actionType;
    gameRequestDialog.content                   = content;
    
    FacebookSharingDelegate* delegate           = [[FacebookSharingDelegate alloc] initWithSharer:self andCallbackID:cbID ? [cbID longValue] : 0];
    delegate.shareInfo                          = shareInfo;

    [gameRequestDialog setDelegate:delegate];
    [gameRequestDialog show];

}

@end
