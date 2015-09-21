//
//  BaaSParse.m
//  PluginParse
//
//  Created by Duc Nguyen on 8/14/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//


#import "BaaSParse.h"
#import "BaaSWrapper.h"
#import "ProtocolBaaS.h"
#include "ParseUtils.h"

using namespace cocos2d::plugin;

static BOOL sIsSet = false;

@implementation BaaSParse

- (void) configDeveloperInfo:(NSMutableDictionary *)devInfo
{

    if (!sIsSet) {
        [Parse enableLocalDatastore];
    }

    NSString* appId = [devInfo objectForKey:@"ParseApplicationId"];
    NSString* clientKey = [devInfo objectForKey:@"ParseClientKey"];

    [Parse setApplicationId:appId clientKey:clientKey];

    _currentConfig = [PFConfig currentConfig];

    sIsSet = true;
}

- (void) signUpWithParams:(NSDictionary *)params
{
    PFUser* user = [PFUser user];
    user.username = [params objectForKey:@"username"];
    user.password = [params objectForKey:@"password"];
    user.email = [params objectForKey:@"email"];
    
    for (NSString* key in [params keyEnumerator]) {
        if ([key compare:@"username"] != NSOrderedSame &&
            [key compare:@"password"] != NSOrderedSame &&
            [key compare:@"email"] != NSOrderedSame)
            user[key] = [params objectForKey:key];
    }
    
    [user signUpInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
        if (!error) {
            
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kSignUpSucceed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            NSLog(@"Hooray! Let them use the app now.");

        } else {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kSignUpFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Error: %@", [error userInfo][@"error"]);
        }
    }];
}

- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError* error) {
        if (user) {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kLoginSucceed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Login successfully.");
        } else {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kLogoutFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Error when logging in. %@", [error userInfo][@"error"]);
        }
    }];
}

- (void) logout
{
    [PFUser logOutInBackgroundWithBlock:^(NSError* error) {
        if (error) {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kLogoutSucceed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Logout error.");
        } else {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kLogoutFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Logout successfully.");
        }
    }];
}

- (BOOL) isLoggedIn
{
    return [PFUser currentUser] != nil;
}

- (void) saveObjectInBackground:(NSString *)className withParams:(NSDictionary*) obj {
    PFObject* parseObj = [PFObject objectWithClassName:className dictionary:obj];
    
    [parseObj saveInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
        if (succeed) {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kSaveSucceed andMsg:parseObj.objectId];
            
            NSLog(@"Save object successful.");
        } else {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kSaveFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Error when saving object. Error: %@", error.description);
        }
    }];
}

- (NSString*) saveObject:(NSString *)className withParams:(NSDictionary *)obj {
    PFObject* parseObj = [PFObject objectWithClassName:className dictionary:obj];
    
    BOOL ret = [parseObj save];
    if (ret) {
        return parseObj.objectId;
    }
    
    return nil;
}

+ (NSDictionary*) convertToDictionary: (PFObject*) object {
    NSArray * allKeys = [object allKeys];
    NSMutableDictionary * retDict = [[NSMutableDictionary alloc] init];

    for (NSString * key in allKeys) {
        [retDict setObject:[object objectForKey:key] forKey:key];
    }
    return retDict;
}

- (void) getObjectInBackground: (NSString*) className withId: (NSString*) objId {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query getObjectInBackgroundWithId:objId block:^(PFObject *object,  NSError *error) {
        if (object) {
            
            
            NSString *result = [ParseUtils NSDictionaryToNSString: [BaaSParse convertToDictionary:object]];
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kRetrieveSucceed andMsg:result];
            
            NSLog(@"Retrieve object successfully.");
        } else {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kRetrieveFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Retrieve object fail.");
        }
    }];
}

- (NSDictionary*) getObject: (NSString*) className withId: (NSString*) objId {
    PFQuery *query = [PFQuery queryWithClassName:className];
    PFObject* object = [query getObjectWithId:objId];
    
    if (!object) {
        NSLog(@"Retrieve object fail.");
        return nil;
    }
    
    NSLog(@"Retrieve object successfully.");
    
    return [BaaSParse convertToDictionary:object];
}

- (void) updateObjectInBackground:(NSString *)className withId:(NSString *)objId withParams:(NSDictionary *)params {
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:objId block:^(PFObject *object, NSError *error) {
        if (error) {
            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kUpdateFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
            
            NSLog(@"Update object fail when retrieving data. Error: %@", error.description);
        }
        
        for (NSString* key in [params keyEnumerator]) {
            object[key] = [params objectForKey:key];
        }
        
        [object saveInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
            if (succeed) {
                [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kUpdateSucceed andMsg:object.objectId];
                
                NSLog(@"Update object succesffully.");
            } else {
                [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kUpdateFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
                
                NSLog(@"Update object fail when saving data.");
            }
        }];
     }];
    
}

- (NSString*) updateObject:(NSString *)className withId:(NSString *)objId withParams:(NSDictionary *)params {
    PFQuery* query = [PFQuery queryWithClassName:className];
    
    PFObject* object = [query getObjectWithId:objId];
    
    if (object) {
        for (NSString* key in [params keyEnumerator]) {
            object[key] = [params objectForKey:key];
        }
        
        BOOL ret = [object save];
        if (ret) {
            NSLog(@"Update object successful.");
            return object.objectId;
        } else {
            NSLog(@"Update object fail when saving data.");
            return nil;
        }
    } else {
        NSLog(@"Update object fail when retrieving data.");
    }
    return nil;
}

- (void) deleteObject: (NSString*) className withId: (NSString*) objId {
    PFQuery* query = [PFQuery queryWithClassName:className];

    PFObject *object = [query getObjectWithId:objId];

    if (object) {
        BOOL ret = [object delete];
        if (ret) {
            NSLog(@"Delete object successfully");
        } else {
            NSLog(@"Delete object failed");
        }
    } else {
        NSLog(@"Object not found");
    }
}

- (void) deleteObjectInBackground: (NSString*) className withId: (NSString*) objId {
    PFQuery* query = [PFQuery queryWithClassName:className];

    [query getObjectInBackgroundWithId:objId block:^(PFObject* object, NSError* error) {
        if (object && error == nil) {
            [object deleteInBackgroundWithBlock:^(BOOL succeed, NSError* error2) {
                if (succeed && error2 == nil) {
                    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kDeleteSucceed andMsg:object.objectId];

                    NSLog(@"Delete object successfully with ID: %@ ", objId);
                } else {
                    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kDeleteFailed andMsg:[BaaSWrapper makeErrorJsonString:error]];
                    
                    NSLog(@"Delete object failed with ID: %@", objId);
                }
            }];
        } else {
            NSLog(@"Object not found");
        }
    }];
}

- (void) fetchConfigInBackground {
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            _currentConfig = config;

            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kFetchConfigSucceed andMsg:@"Fetch successfully"];

            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            _currentConfig = [PFConfig currentConfig];

            [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kFetchConfigFailed andMsg:@"Fetch failed, use locally."];

            NSLog(@"Failed to fetch. Using Cached Config.");
        }
    }];
}

- (BOOL) getBoolConfig: (NSString*) param {
    bool ret = [_currentConfig[param] boolValue];
    NSString* msg = [NSString stringWithFormat:@"Get bool config: %d", ret];

    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kGetBoolConfig andMsg:msg];
    return ret;
}

- (int) getIntegerConfig: (NSString*) param {
    int ret = (int)[_currentConfig[param] integerValue];
    NSString* msg = [NSString stringWithFormat:@"Get int config: %d", ret];

    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kGetIntConfig andMsg:msg];
    return ret;
}

- (double) getDoubleConfig: (NSString*) param {
    auto ret = [_currentConfig[param] doubleValue];
    NSString* msg = [NSString stringWithFormat:@"Get double config: %f", ret];

    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kGetDoubleConfig andMsg:msg];
    return ret;
}

- (long) getLongConfig: (NSString*) param {
    auto ret = [_currentConfig[param] longValue];
    NSString* msg = [NSString stringWithFormat:@"Get long config: %ld", ret];

    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kGetLongConfig andMsg:msg];
    return ret;
}

- (NSString*) getStringConfig: (NSString*) param {
    NSString* ret = _currentConfig[param];
    NSString* msg = [NSString stringWithFormat:@"Get string config: %@", ret];

    [BaaSWrapper onActionResult:self withRet:(int)BaaSActionResultCode::kGetStringConfig andMsg:msg];
    return ret;
}

- (NSDictionary*) getUserInfo {
    PFUser* pfUser = [PFUser currentUser];
    if (pfUser) {
    
        return [BaaSParse convertToDictionary:pfUser];
    
    }
    
    return nil;
}

- (NSString*) getSDKVersion
{
    return @"";
}

- (NSString*) getPluginVersion
{
    return @"";
}

@end
