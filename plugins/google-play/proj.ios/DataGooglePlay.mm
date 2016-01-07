//
//  DataGooglePlay.m
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import "DataGooglePlay.h"
#import "DataWrapper.h"
#include <map>

using namespace std;
using namespace cocos2d::plugin;

@interface DataGooglePlay() <GPGStatusDelegate, GPGSnapshotListLauncherDelegate>

@end

@implementation DataGooglePlay

@synthesize clientID = _clientID;
@synthesize currentSnapshot = _currentSnapshot;
@synthesize conflictId = _conflictId;
@synthesize conflictingSnapshotBase = _conflictingSnapshotBase;
@synthesize conflictingSnapshotRemote = _conflictingSnapshotRemote;
@synthesize snapshotListTitle = _snapshotListTitle;
@synthesize shouldAllowSnapshotCreate = _shouldAllowSnapshotCreate;
@synthesize shouldAllowSnapshotDelete = _shouldAllowSnapshotDelete;
@synthesize maxSlots = _maxSlots;

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo
{
    _clientID = (NSString*) [devInfo objectForKey:@"GoogleClientID"];
    [GPGManager sharedInstance].statusDelegate = self;
    [GPGManager sharedInstance].snapshotsEnabled = YES;
    [[GPGManager sharedInstance] signInWithClientID:_clientID silently:YES];
}

- (void) presentSnapshotList {
    [GPGLauncherController sharedInstance].snapshotListLauncherDelegate = self;
    [[GPGLauncherController sharedInstance] presentSnapshotList];
}

- (void) openDataWithFileName: (NSString*) fileName andConflictPolicy: (cocos2d::plugin::DataConflictPolicy) policy {
    
    map<int, int> valueMap;
    valueMap[kConflictPolicyManual] = GPGSnapshotConflictPolicyManual;
    valueMap[kConflictPolicyHighestProgress] = GPGSnapshotConflictPolicyHighestProgress;
    valueMap[kConflictPolicyLastKnownGood] = GPGSnapshotConflictPolicyLastKnownGood;
    valueMap[kConflictPolicyMostRecentlyModified] = GPGSnapshotConflictPolicyMostRecentlyModified;
    valueMap[kConflictPolicyLongestPlaytime] = GPGSnapshotConflictPolicyLongestPlaytime;

    [GPGSnapshotMetadata openWithFileName:fileName conflictPolicy: (GPGSnapshotConflictPolicy) valueMap[policy] completionHandler:^(GPGSnapshotMetadata *snapshot, NSString *conflictId, GPGSnapshotMetadata *conflictingSnapshotBase, GPGSnapshotMetadata *conflictingSnapshotRemote, NSError *error) {
        
        if (error) {
            NSLog(@"Error when open file: %@", error.description);
            [DataWrapper onDataResult:self withRet:kOpenFailed withData:nil];
        } else if (conflictId) {
            NSLog(@"Conflicting when open file! Try to resolve before do anything else!");
            [DataWrapper onDataResult:self withRet:kOpenConflicting withData:nil];
        } else {
            NSLog(@"Open successfully");
            self.currentSnapshot = snapshot;
            self.conflictingSnapshotBase = conflictingSnapshotBase;
            self.conflictingSnapshotRemote = conflictingSnapshotRemote;
            self.conflictId = conflictId;
            _lastOpen =  [[NSDate date] timeIntervalSince1970];
            [DataWrapper onDataResult:self withRet:kOpenSucceed withData: nil];
        }
    }];
}

+ (NSDictionary*) convertSnapshotMetadataToDictionary: (GPGSnapshotMetadata*) snapshot
{
    if (snapshot) {
        NSDictionary* info = [[[NSDictionary alloc] initWithObjects:
                              @[snapshot.fileName,
                                snapshot.snapshotDescription,
                                [NSNumber numberWithLong:(long)snapshot.lastModifiedTimestamp],
                                [NSNumber numberWithLong:(long)snapshot.playedTime],
                                [NSNumber numberWithLong:(long)snapshot.progressValue],
                                snapshot.coverImageUrl.absoluteString]
                                                           forKeys:
                              @[@"file-name",
                                @"description",
                                @"last-modified",
                                @"played-time",
                                @"progress-value",
                                @"cover-image"]] autorelease];
        return info;
    } else {
        return nil;
    }
}

- (NSDictionary*) getCurrentMetaDataInfo {
    return [DataGooglePlay convertSnapshotMetadataToDictionary:_currentSnapshot];
}

- (NSDictionary*) getConflictingMetadataBase {
    return [DataGooglePlay convertSnapshotMetadataToDictionary:_conflictingSnapshotBase];
}

- (NSDictionary*) getConflictingMetadataRemote {
    return [DataGooglePlay convertSnapshotMetadataToDictionary:_conflictingSnapshotRemote];
}

- (void) readCurrentData {
    if (_currentSnapshot && _currentSnapshot.isOpen) {
        [_currentSnapshot readWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"Read data failed.");
                [DataWrapper onDataResult:self withRet:kReadFailed withData:nil];
            } else {
                NSLog(@"Read data successfully");
                [DataWrapper onDataResult:self withRet:kReadSucceed withData:data];
            }
        }];
    } else {
        NSLog(@"Not open data yet!.");
        [DataWrapper onDataResult:self withRet:kReadFailed withData:nil];
    }
}

- (void) commitCurrentData:(NSData *)data withImage:(NSString *)path andDescription:(NSString *)description {
    if (!self.currentSnapshot.isOpen) {
        NSLog(@"Error trying to commit a snapshot. You must always open it first");
        [DataWrapper onDataResult:self withRet:kWriteFailed withData:nil];
        return;
    }
    
    // Create a snapshot change to be committed with a description,
    // cover image, and play time.
    GPGSnapshotMetadataChange *dataChange = [[[GPGSnapshotMetadataChange alloc] init] autorelease];
    dataChange.snapshotDescription = description;
    
    // Note: This is done for simplicity. You should record time since
    // your game last opened a saved game.
    int millsSinceaPreviousSnapshotWasOpened =  [[NSDate date] timeIntervalSince1970] - _lastOpen;
    dataChange.playedTime = self.currentSnapshot.playedTime + millsSinceaPreviousSnapshotWasOpened;
    
    if (path) {
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        dataChange.coverImage = [[[GPGSnapshotMetadataChangeCoverImage alloc]
                                 initWithImage:image] autorelease];
    }
    
    [self.currentSnapshot commitWithMetadataChange:dataChange data: data completionHandler:^(GPGSnapshotMetadata *snapshotMetadata, NSError *error) {
             if (!error) {
                 NSLog(@"Successfully saved %@", snapshotMetadata);
                 [DataWrapper onDataResult:self withRet:kWriteSucceed withData:data];
             } else {
                 NSLog(@"** Error while saving: %@", error);
                 [DataWrapper onDataResult:self withRet:kWriteFailed withData:data];
             }
             self.currentSnapshot = nil;
        }
     ];
}

- (void) resolveConflict:(NSString *)conflictId withData: (NSData*) data andInfo: (NSDictionary*) changes {
    
    GPGSnapshotMetadataChange *change = [[[GPGSnapshotMetadataChange alloc]init] autorelease];
    change.snapshotDescription = [NSString stringWithFormat:@"Merge conflict %@", conflictId];
    change.playedTime = [[changes objectForKey:@"played-time"] longValue];
    change.progressValue = [[changes objectForKey:@"progress-value"] longValue];
    
    [_currentSnapshot resolveWithMetadataChange:change conflictId:conflictId data:data completionHandler:^(GPGSnapshotMetadata *snapshotMetadata, NSError *error) {
       
        if (error) {
            NSLog(@"Resolve error. %@", error.description);
            [DataWrapper onDataResult:self withRet:kResolveFailed withData:nil];
        } else {
            NSLog(@"Resolve successfully");
            [DataWrapper onDataResult:self withRet:kResolveSucceed withData:nil];
        }
    }];
}

#pragma mark -
#pragma mark Interface of GPGStatusDelegate

- (void)didFinishGamesSignInWithError:(NSError *)error
{
    NSLog(@"[ProtocolData] Did finish signin game play service. Error: %@", error.description);
}

- (void)didFinishGamesSignOutWithError:(NSError *)error
{
    NSLog(@"[ProtocolData] Did finish signout game play service. Error: %@", error.description);
}

- (void)didFinishGoogleAuthWithError:(NSError *)error
{
    NSLog(@"[ProtocolData] Did finish authorize game play service. Error: %@", error.description);
}

- (BOOL)shouldReauthenticateWithError:(NSError *)error
{
    NSLog(@"[ProtocolData] Should reauthorize game play service. Error: %@", error.description);
    return NO;
}

- (void)willReauthenticate:(NSError *)error
{
     NSLog(@"[ProtocolData] Will reauthorize game play service. Error: %@", error.description);
}

- (void)didDisconnectWithError:(NSError *)error
{
     NSLog(@"[ProtocolData] Did disconnect game play service. Error: %@", error.description);
}

#pragma mark -
#pragma mark Interface of GPGSnapshotListLauncherDelegate

- (void)snapshotListLauncherDidTapSnapshotMetadata:(GPGSnapshotMetadata *)snapshot
{
    NSLog(@"Selected snapshot metadata: %@", snapshot.snapshotDescription);
    
    [GPGSnapshotMetadata openWithFileName:snapshot.fileName conflictPolicy:GPGSnapshotConflictPolicyManual completionHandler:^(GPGSnapshotMetadata *snapshot, NSString *conflictId, GPGSnapshotMetadata *conflictingSnapshotBase, GPGSnapshotMetadata *conflictingSnapshotRemote, NSError *error) {
       
        [snapshot readWithCompletionHandler:^(NSData *data, NSError *error) {
            
            if (!error) {
                int intData = *( (int*) data.bytes);
                
                NSLog(@"Save game data: %d", intData);
            } else {
                NSLog(@"Read saved game error: %@", error.description);
            }
        }];
        
    }];
}

- (void)snapshotListLauncherDidCreateNewSnapshot
{
    NSLog(@"New snapshot selected");
    
    
    [GPGSnapshotMetadata openWithFileName:@"Default" conflictPolicy:GPGSnapshotConflictPolicyLastKnownGood completionHandler:^(GPGSnapshotMetadata *snapshot, NSString *conflictId, GPGSnapshotMetadata *conflictingSnapshot, GPGSnapshotMetadata *conflictingSnapshotUnmerged, NSError *error) {
        
        NSLog(@"Error: %@", error.description);
        
        GPGSnapshotMetadataChange* change = [[[GPGSnapshotMetadataChange alloc] init] autorelease];
        change.snapshotDescription = @"Update data";
        
        int x = 1;
        
        NSData *data = [[[NSData alloc] initWithBytes:&x length:sizeof(x)] autorelease];
        
        [snapshot commitWithMetadataChange:change data:data completionHandler:^(GPGSnapshotMetadata *snapshotMetadata, NSError *error) {
            NSLog(@"Error: %@", error.description);
        }];
    }];
}

- (NSString *)titleForSnapshotListLauncher
{
    return _snapshotListTitle;
}

- (BOOL)shouldAllowCreateForSnapshotListLauncher
{
    return _shouldAllowSnapshotCreate;
}

- (BOOL)shouldAllowDeleteForSnapshotListLauncher
{
    return _shouldAllowSnapshotDelete;
}

- (int)maxSaveSlotsForSnapshotListLauncher
{
    return _maxSlots;
}

@end
