//
//  InterfaceData.h
//  PluginProtocol
//
//  Created by Duc Nguyen on 7/27/15.
//

#ifndef PluginProtocol_InterfaceData_h
#define PluginProtocol_InterfaceData_h

#import <Foundation/Foundation.h>

@protocol InterfaceData <NSObject>

- (void) configDeveloperInfo: (NSMutableDictionary*) devInfo;
- (void) openDataWithFileName: (NSString*) fileName andConflictPolicy: (int) policy;
- (void) readCurrentData;
- (void) resolveConflict: (NSString*) conflictId withData: (NSData*) data andInfo: (NSDictionary*) changes;
- (void) commitCurrentData: (NSData*) data withImage: (NSString*) path andDescription: (NSString*) description;


@end

#endif
