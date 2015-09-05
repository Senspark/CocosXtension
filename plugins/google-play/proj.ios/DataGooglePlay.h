//
//  DataGooglePlay.h
//  PluginGooglePlay
//
//  Created by Duc Nguyen on 8/10/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <gpg/GooglePlayGames.h>
#import "InterfaceData.h"
#import "ProtocolData.h"

@interface DataGooglePlay : NSObject<InterfaceData>
{
    int64_t _lastOpen;
}

@property (copy, nonatomic) NSString* clientID;
@property (retain, nonatomic) GPGSnapshotMetadata* currentSnapshot;
@property (retain, nonatomic) GPGSnapshotMetadata* conflictingSnapshotBase;
@property (retain, nonatomic) GPGSnapshotMetadata* conflictingSnapshotRemote;
@property (retain, nonatomic) NSString* conflictId;
@property (retain, nonatomic) NSString* snapshotListTitle;
@property (assign) BOOL shouldAllowSnapshotCreate;
@property (assign) BOOL shouldAllowSnapshotDelete;
@property (assign) int  maxSlots;

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;

- (void) presentSnapshotList;

- (void) openDataWithFileName: (NSString*) fileName andConflictPolicy: (cocos2d::plugin::DataConflictPolicy) policy;
- (void) readCurrentData;
- (void) resolveConflict: (NSString*) conflictId withData: (NSData*) data andInfo: (NSDictionary*) changes;
- (void) commitCurrentData: (NSData*) data withImage: (NSString*) path andDescription: (NSString*) description;

- (NSDictionary*) getCurrentMetaDataInfo;
- (NSDictionary*) getConflictingMetadataBase;
- (NSDictionary*) getConflictingMetadataRemote;

@end
