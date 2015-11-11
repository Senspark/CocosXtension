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

@synthesize mShareInfo;
@synthesize debug = __debug;

/**
 * A function for parsing URL parameters.
 */
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

/**
 * shareInfo parameters support both AnySDK style and facebook style
 *  1. AnySDK style
 *      - title
 *      - site
 *      - siteUrl
 *      - text
 *      - imageUrl
 *      - imagePath
 *
 *  2. Facebook style
 *      - caption
 *      - name
 *      - link
 *      - description
 *      - picture
 */

- (void)convertParamsToFBParams:(NSMutableDictionary*) shareInfo {
    // Link type share info
    NSString *link = [shareInfo objectForKey:@"siteUrl"];
    if (!link) {
        link = [shareInfo objectForKey:@"link"];
    }
    else {
        [shareInfo setObject:link forKey:@"link"];
    }
    // Photo type share info
    NSString *photo = [shareInfo objectForKey:@"imageUrl"];
    if (!photo) {
        photo = [shareInfo objectForKey:@"imagePath"];
    }
    if (!photo) {
        photo = [shareInfo objectForKey:@"photo"];
    }
    else {
        [shareInfo setObject:photo forKey:@"photo"];
        [shareInfo setObject:photo forKey:@"picture"];
    }
    
    // Title
    NSString *caption = [shareInfo objectForKey:@"title"];
    if (!caption) {
        link = [shareInfo objectForKey:@"caption"];
    }
    else {
        [shareInfo setObject:caption forKey:@"caption"];
    }
    
    // Site name
    NSString *name = [shareInfo objectForKey:@"site"];
    if (!name) {
        link = [shareInfo objectForKey:@"name"];
    }
    else {
        [shareInfo setObject:name forKey:@"name"];
    }
    
    // Description
    NSString *desc = [shareInfo objectForKey:@"text"];
    if (!desc) {
        link = [shareInfo objectForKey:@"description"];
    }
    else {
        [shareInfo setObject:desc forKey:@"description"];
    }
}

- (void) configDeveloperInfo : (NSMutableDictionary*) cpInfo
{
}

- (void) share: (NSMutableDictionary*) shareInfo
{
    [self convertParamsToFBParams:shareInfo];
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
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];

    }
    else if (photo) {
        NSURL *photoUrl = [NSURL URLWithString:[shareInfo objectForKey:@"photo"]];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:photoUrl]];
        
        FBSDKSharePhoto* sharePhoto = [[FBSDKSharePhoto alloc] init];
        sharePhoto.image = img;
        
        FBSDKSharePhotoContent* content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[sharePhoto];
        
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];
    }
    else if (video) {
        FBSDKShareVideo *shareVideo = [[FBSDKShareVideo alloc] init];
        shareVideo.videoURL = [NSURL URLWithString:video];
        
        FBSDKShareVideoContent *content = [[FBSDKShareVideoContent alloc] init];
        content.video = shareVideo;
        
        [FBSDKShareDialog showFromViewController:[ShareWrapper getCurrentRootViewController] withContent:content delegate:self];
        
    } else {
        NSString *msg = [ParseUtils MakeJsonStringWithObject:@"Share failed, share target absent or not supported, please add 'siteUrl' or 'imageUrl' in parameters" andKey:@"error_message"];
        [ShareWrapper onShareResult:self withRet:kShareFail withMsg:msg];
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
    return @"0.3.0";
}

#pragma mark -
#pragma Facebook Sharing Delegate
/*!
@abstract Sent to the delegate when the share completes without error or cancellation.
@param sharer The FBSDKSharing that completed.
@param results The results from the sharer.  This may be nil or empty.
*/
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [ShareWrapper onShareResult:self withRet:kShareSuccess withMsg:[ParseUtils NSDictionaryToNSString:results]];
}

/*!
@abstract Sent to the delegate when the sharer encounters an error.
@param sharer The FBSDKSharing that completed.
@param error The error.
*/
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [ShareWrapper onShareResult:self withRet:kShareFail withMsg:error.description];
}

/*!
@abstract Sent to the delegate when the sharer is cancelled.
@param sharer The FBSDKSharing that completed.
*/
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    [ShareWrapper onShareResult:self withRet:kShareCancel withMsg:@"User cancelled request"];
}


-(void)appRequest:(NSMutableDictionary*)requestInfo{
    [self convertParamsToFBParams:requestInfo];
    

}

#pragma mark - facebook invite


-(void) fetchInvitableFriendList:(NSMutableDictionary*) fetchInfo{
    [self convertParamsToFBParams:fetchInfo];
    NSString *nsLimit = [fetchInfo objectForKey:@"limit"];
    
    int limit;
    if(nsLimit != nil){
        limit = [nsLimit intValue];
    }else{
        limit = 50;
    }
    if(limit > 50){
        limit = 50;
    }
    
    FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/invitable_friends?limit=300"
                                                                    parameters:nil
                                                                    HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection* connection, id result, NSError* error) {
        if (error == nil) {
            //result -> dictionary -> json string -> call callback (msg)
            NSString* friendsList = @"";
            NSArray* friends = [result objectForKey:@"data"];
            if(friends.count>0){
                
                friendsList = [friendsList stringByAppendingString:@"["];
                
                int ran;
                if(friends.count>limit){
                    unsigned ranLimit = friends.count-limit;
                    ran = rand() % ranLimit;
                }else{
                    ran = 0;
                }
                
                for(int i=0; i<limit; i++){
                    id obj = [friends objectAtIndex:ran];
                    NSString* friendJson = [ParseUtils NSDictionaryToNSString:obj];
                    friendsList = [friendsList stringByAppendingString:friendJson];
                    if(i < (limit-1) && ran < friends.count-1){
                        friendsList = [friendsList stringByAppendingString:@","];
                    }
                    if(ran >= friends.count-1){
                        break;
                    }
                    ran++;
                }
                friendsList = [friendsList stringByAppendingString:@"]"];
                // NSLog(@"list friends : %@",friendsList);
            }
            
            [ShareWrapper onShareResult:self withRet:kFetchInvitableFriendsSuccess withMsg:friendsList];
        } else {
            NSLog(@"fetchInvitableFriendList error %@", error);
            [ShareWrapper onShareResult:self withRet:kFetchInvitableFreindsFailed withMsg:@"fetch failed"];
        }
    }];
}

-(void) openInviteDialog:(NSMutableDictionary*) shareInfo{
    [self convertParamsToFBParams:shareInfo];
    NSString *recipients = [shareInfo objectForKey:@"recipients"];
    
    FBSDKGameRequestDialog* gameRequestDialog   = [[FBSDKGameRequestDialog alloc] init];
    FBSDKGameRequestContent* content            = [[FBSDKGameRequestContent alloc] init];
    content.title                               = @"Invite friends";
    content.message                             = @"send request to friends";
    content.data                                = @"INVITE_FRIENDS";
    content.recipients                          = [recipients componentsSeparatedByString:@","];
    gameRequestDialog.content                   = content;
    gameRequestDialog.delegate                  = self;
    gameRequestDialog.frictionlessRequestsEnabled = YES;
    [gameRequestDialog show];
}

/**
 implement request method
 */
- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didCompleteWithResults:(NSDictionary*) results {
    NSLog(@"data content request dialog %@",gameRequestDialog.content.data);
    [ShareWrapper onShareResult:self withRet:kRequestSuccess withMsg:@"request success"];
}

- (void) gameRequestDialog:(FBSDKGameRequestDialog*) gameRequestDialog didFailWithError:(NSError*) error {
    [ShareWrapper onShareResult:self withRet:kRequestFailed withMsg:@"request failed"];
}

- (void) gameRequestDialogDidCancel:(FBSDKGameRequestDialog*) gameRequestDialog {
    [ShareWrapper onShareResult:self withRet:kRequestCancel withMsg:@"request cancel"];
}


@end