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

- (void) signUpWithParams:(NSDictionary *)params andCallbackID:(long) cbID
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
            [BaaSWrapper onBaaSActionResult:self withReturnCode: (int)BaaSActionResultCode::kSignUpSucceed andReturnMsg:[self getUserInfo] andCallbackID:cbID];

            NSLog(@"Hooray! Let them use the app now.");

        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSignUpFailed andReturnMsg: [BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error: %@", [error userInfo][@"error"]);
        }
    }];
}

- (void) loginWithFacebookAccessToken: (NSNumber*) callbackID {
    [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        
        long cbID = callbackID ? [callbackID longValue] : 0;
        
        if (user) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLoginSucceed andReturnMsg:[self getUserInfo] andCallbackID:cbID];
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLoginFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error when logging in. %@", [error userInfo][@"error"]);
        }
        
    }];
}

- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password andCallbackID: (long) cbID
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError* error) {
        if (user) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLoginSucceed andReturnMsg:[self getUserInfo] andCallbackID:cbID];
            
            NSLog(@"Login successfully.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLoginFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error when logging in. %@", [error userInfo][@"error"]);
        }
    }];
}

- (void) logout: (long) cbID
{
    [PFUser logOutInBackgroundWithBlock:^(NSError* error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLogoutSucceed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Logout error.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kLogoutFailed andReturnMsg:@"" andCallbackID:cbID];
            
            NSLog(@"Logout successfully.");
        }
    }];
}

- (BOOL) isLoggedIn
{
    return [PFUser currentUser] != nil;
}

- (void) saveObjectInBackground:(NSString *)className withParams:(NSDictionary*) obj andCallbackID:(long) cbID {
    PFObject* parseObj = [PFObject objectWithClassName:className dictionary:obj];
    
    [parseObj saveInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
        if (succeed) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveSucceed andReturnObj:[BaaSParse convertPFObjectToDictionary:parseObj] andCallbackID:cbID];
            
            NSLog(@"Save object successful.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error when saving object. Error: %@", [BaaSWrapper makeErrorJsonString:error]);
        }
    }];
}

- (NSString*) getUserID {
    return [PFUser currentUser].objectId;
}

- (NSString*) getUserInfo {
    return [ParseUtils NSDictionaryToNSString:[BaaSParse convertPFUserToDictionary:[PFUser currentUser]]];
}

- (NSString*) setUserInfo: (NSString*) jsonChanges {
    NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:jsonChanges];
    PFUser* parseUser = [PFUser currentUser];
    
    if (parseUser) {
        for (NSString* key in [params keyEnumerator]) {
            parseUser[key] = [params objectForKey:key];
        }
        
        return [self getUserInfo];
    }
    
    return @"";
}

- (void) saveUserInfo: (NSNumber*) cbID {
    long cb = cbID ? [cbID longValue] : 0;
    PFUser* parseUser = [PFUser currentUser];
    if (parseUser) {
        [parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveSucceed andReturnObj:[BaaSParse convertPFUserToDictionary:parseUser] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:@"" andCallbackID:cb];
    }
}

- (void) fetchUserInfo: (NSNumber*) cbID {
    long cb = cbID ? [cbID longValue] : 0;
    PFUser* parseUser = [PFUser currentUser];
    if (parseUser) {
        [parseUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveSucceed andReturnObj:[BaaSParse convertPFUserToDictionary:parseUser] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:@"" andCallbackID:cb];
    }
}

- (NSString*) getInstallationInfo {
    return [ParseUtils NSDictionaryToNSString:[BaaSParse convertPFObjectToDictionary:[PFInstallation currentInstallation]]];
}

- (NSString*) setInstallationInfo:(NSString *)json {
    NSDictionary* params = [ParseUtils NSStringToArrayOrNSDictionary:json];
    
    PFInstallation* installation = [PFInstallation currentInstallation];
    
    if (installation) {
        for (NSString* key in [params keyEnumerator]) {
            installation[key] = [params objectForKey:key];
        }
        
        return [self getInstallationInfo];
    }
    
    return @"";
}

- (void) saveInstallationInfo:(NSNumber *)cbID {
    long cb = cbID ? [cbID longValue] : 0;
    PFInstallation* parseInstall = [PFInstallation currentInstallation];
    
    if (parseInstall) {
        [parseInstall saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveSucceed andReturnObj:[BaaSParse convertPFObjectToDictionary:parseInstall] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kSaveFailed andReturnMsg:@"" andCallbackID:cb];
    }
}


- (NSString*) saveObject:(NSString *)className withParams:(NSDictionary *)obj {
    PFObject* parseObj = [PFObject objectWithClassName:className dictionary:obj];
    
    BOOL ret = [parseObj save];
    if (ret) {
        return parseObj.objectId;
    }
    
    return nil;
}

+ (NSMutableDictionary*) convertPFObjectToDictionary: (PFObject*) object {
    if (object) {
        NSArray * allKeys = [object allKeys];
        NSMutableDictionary * objectDict = [[NSMutableDictionary alloc] init];
        
        for (NSString * key in allKeys) {
            [objectDict setObject:[object objectForKey:key] forKey:key];
        }
        
        [objectDict setObject:[NSNumber numberWithDouble:[object.createdAt timeIntervalSince1970]] forKey:@"createdAt"];
        [objectDict setObject:[NSNumber numberWithDouble:[object.updatedAt timeIntervalSince1970]] forKey:@"updatedAt"];
        
        return objectDict;
    }
    return nil;
}

+ (NSMutableDictionary*) convertPFUserToDictionary: (PFUser*) user {
    NSMutableDictionary* userDict = [BaaSParse convertPFObjectToDictionary:user];
    
    if (userDict) {
        [userDict setObject:[NSNumber numberWithBool:user.isNew] forKey:@"isNew"];
        
        return userDict;
    }
    return nil;
}

- (void) getObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query getObjectInBackgroundWithId:objId block:^(PFObject *object,  NSError *error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveFailed andReturnObj:nil andCallbackID:cbID];
            
            NSLog(@"Retrieve object fail.");
            
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveSucceed andReturnObj:[BaaSParse convertPFObjectToDictionary:object] andCallbackID:cbID];
            
            NSLog(@"Retrieve object successfully.");
        }
    }];
}

- (void) getObjectsInBackground: (NSString*) className withIds:(NSArray *)objIds andCallbackID:(long) cbID {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"objectId" containedIn:objIds];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveFailed andReturnObj:nil andCallbackID:cbID];
            
            NSLog(@"Retrieve object fail.");
        } else {
            NSMutableArray* objArr = [[NSMutableArray alloc] init];
            for (PFObject* obj : objects) {
                [objArr addObject:[BaaSParse convertPFObjectToDictionary:obj]];
            }
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveSucceed andReturnObj:objArr andCallbackID:cbID];

            NSLog(@"Retrieve object successfully.");
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
    
    return [BaaSParse convertPFObjectToDictionary:object];
}

- (void) fetchObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID {
    PFObject* parseObj = [PFObject objectWithoutDataWithObjectId:objId];

    [parseObj fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveSucceed andReturnObj:[BaaSParse convertPFObjectToDictionary:parseObj] andCallbackID:cbID];
        }
    }];
}

- (void) findObjectsInBackground: (NSString*) className whereKey: (NSString*) key containedIn: (NSArray*) values  withCallbackID:(long)callbackId {
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:key containedIn:values];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode: (int) BaaSActionResultCode::kRetrieveFailed andReturnMsg: [BaaSWrapper makeErrorJsonString:error] andCallbackID:callbackId];
            
            NSLog(@"Retrieve object fail.");
        } else {
            NSMutableArray* objArr = [[NSMutableArray alloc] init];
            for (PFObject* obj : objects) {
                [objArr addObject:[BaaSParse convertPFObjectToDictionary:obj]];
            }
            
            NSString *result = [ParseUtils NSArrayToNSString:objArr];
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kRetrieveSucceed andReturnMsg:result andCallbackID:callbackId];
            
            NSLog(@"Retrieve object successfully.");
        }
    }];
}


- (void) findObjectInBackground: (NSString*) className whereKey: (NSString*) key equalTo: (NSString*) value    withCallbackID: (long) callbackId {
    PFQuery* query = [PFQuery queryWithClassName:className];
    [query whereKey:key equalTo:value];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int) BaaSActionResultCode::kRetrieveFailed andReturnMsg:@"" andCallbackID:callbackId];
            NSLog(@"Retrieve object fail.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int) BaaSActionResultCode::kRetrieveSucceed andReturnMsg:@"" andCallbackID:callbackId];
            NSLog(@"Retrieve object successfully.");
        }
    }];
}


- (void) updateObjectInBackground:(NSString *)className withId:(NSString *)objId withParams:(NSDictionary *)params andCallbackID:(long) cbID {
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:objId block:^(PFObject *object, NSError *error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode: (int) BaaSActionResultCode::kUpdateFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Update object fail when retrieving data. Error: %@", [BaaSWrapper makeErrorJsonString:error]);
        }
        
        for (NSString* key in [params keyEnumerator]) {
            object[key] = [params objectForKey:key];
        }
        
        [object saveInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
            if (succeed) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int) BaaSActionResultCode::kUpdateSucceed andReturnMsg:object.objectId  andCallbackID:cbID];
                
                NSLog(@"Update object succesffully.");
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode: (int) BaaSActionResultCode::kUpdateFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];;
                
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

- (BOOL) deleteObject: (NSString*) className withId: (NSString*) objId {
    PFObject *object = [PFObject objectWithoutDataWithClassName:className objectId:objId];
    BOOL ret = false;
    
    ret = [object delete];
    if (ret) {
        NSLog(@"Delete object successfully");
    } else {
        NSLog(@"Delete object failed");
    }
    return ret;
}

- (void) deleteObjectInBackground: (NSString*) className withId: (NSString*) objId andCallbackID:(long) cbID {
    PFObject* object = [PFObject objectWithoutDataWithClassName:className objectId:objId];
    [object deleteInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
        if (succeed && error == nil) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kDeleteSucceed andReturnMsg:object.objectId andCallbackID:cbID];

            NSLog(@"Delete object successfully with ID: %@ ", objId);
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kDeleteFailed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Delete object failed with ID: %@", objId);
        }
    }];
}

- (void) fetchConfigInBackground:(long) cbID{
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            _currentConfig = config;

            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kFetchConfigSucceed andReturnMsg:@"Fetch successfully" andCallbackID:cbID];
            

            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            _currentConfig = [PFConfig currentConfig];

            [BaaSWrapper onBaaSActionResult:self withReturnCode:(int)BaaSActionResultCode::kFetchConfigFailed andReturnMsg:@"Fetch failed, use locally." andCallbackID:cbID];

            NSLog(@"Failed to fetch. Using Cached Config.");
        }
    }];
}

- (BOOL) getBoolConfig: (NSString*) param {
    bool ret = [_currentConfig[param] boolValue];
    NSString* msg = [NSString stringWithFormat:@"Get bool config: %d", ret];

    NSLog(@"%@", msg);
    return ret;
}

- (int) getIntegerConfig: (NSString*) param {
    int ret = (int)[_currentConfig[param] integerValue];
    NSString* msg = [NSString stringWithFormat:@"Get int config: %d", ret];

    NSLog(@"%@", msg);
    return ret;
}

- (double) getDoubleConfig: (NSString*) param {
    auto ret = [_currentConfig[param] doubleValue];
    NSString* msg = [NSString stringWithFormat:@"Get double config: %f", ret];

    NSLog(@"%@", msg);
    return ret;
}

- (long) getLongConfig: (NSString*) param {
    auto ret = [_currentConfig[param] longValue];
    NSString* msg = [NSString stringWithFormat:@"Get long config: %ld", ret];

    NSLog(@"%@", msg);
    return ret;
}

- (NSString*) getStringConfig: (NSString*) param {
    NSString* ret = _currentConfig[param];
    NSString* msg = [NSString stringWithFormat:@"Get string config: %@", ret];

    NSLog(@"%@", msg);
    return ret;
}

- (NSDictionary*) getArrayConfig:(NSString *)param {
    NSDictionary* ret = _currentConfig[param];
    NSString* arr = [NSString stringWithFormat:@"Get array config: %@", ret];

    NSLog(@"%@", arr);
    return ret;
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
