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
#import "ParseUtils.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

using namespace cocos2d::plugin;

@implementation BaaSParse

- (void) configDeveloperInfo:(NSDictionary *)devInfo
{
    NSString* appId         = [devInfo objectForKey:@"ParseApplicationId"];
    NSString* clientKey     = [devInfo objectForKey:@"ParseClientKey"];
    BOOL enableLocalDatastore = [[devInfo objectForKey:@"ParseEnableLocalDatastore"] boolValue];
    BOOL enableFacebookUtils  = [[devInfo objectForKey:@"ParseEnableFacebookUtils"] boolValue];

    if (enableLocalDatastore) {
        [Parse enableLocalDatastore];
    }

    [Parse setApplicationId:appId clientKey:clientKey];
    
    if (enableFacebookUtils) {
        [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:nil];
    }

    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];

    _currentConfig = [PFConfig currentConfig];
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
        if (succeed) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode: succeed andReturnMsg:[self getUserInfo] andCallbackID:cbID];

            NSLog(@"Hooray! Let them use the app now.");

        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg: [BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error: %@", [error userInfo][@"error"]);
        }
    }];
}

- (void) loginWithFacebookAccessToken: (NSNumber*) callbackID {
    [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        
        long cbID = callbackID ? [callbackID longValue] : 0;
        
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error when logging in. %@", [error userInfo][@"error"]);
        }
        else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:[self getUserInfo] andCallbackID:cbID];
        }
    }];
}

- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password andCallbackID: (long) cbID
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError* error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Error when logging in. %@", [error userInfo][@"error"]);
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:[self getUserInfo] andCallbackID:cbID];
            
            NSLog(@"Login successfully.");
        }
    }];
}

- (void) logout: (long) cbID
{
    [PFUser logOutInBackgroundWithBlock:^(NSError* error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Logout error.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:@"" andCallbackID:cbID];
            
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
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnObj:[BaaSParse convertPFObjectToDictionary:parseObj] andCallbackID:cbID];
            
            NSLog(@"Save object successful.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
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
        [parseUser saveInBackgroundWithBlock:^(BOOL succeed, NSError * _Nullable error) {
            if (succeed) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnObj:[BaaSParse convertPFUserToDictionary:parseUser] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:@"" andCallbackID:cb];
    }
}

- (void) fetchUserInfo: (NSNumber*) cbID {
    long cb = cbID ? [cbID longValue] : 0;
    PFUser* parseUser = [PFUser currentUser];
    if (parseUser) {
        [parseUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error) {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:[BaaSParse convertPFUserToDictionary:parseUser] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:@"" andCallbackID:cb];
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
                [BaaSWrapper onBaaSActionResult:self withReturnCode:succeeded andReturnObj:[BaaSParse convertPFObjectToDictionary:parseInstall] andCallbackID:cb];
            } else {
                [BaaSWrapper onBaaSActionResult:self withReturnCode:succeeded andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cb];
            }
        }];
    } else {
        [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:@"" andCallbackID:cb];
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
            id value = [object objectForKey:key];
            if (value && [value isKindOfClass: [PFObject class]]) {
                PFObject* obj = (PFObject*) value;
                [objectDict setObject: obj.objectId forKey:key];
            }
            else {
                [objectDict setObject:[object objectForKey:key] forKey:key];
            }
        }
        
        [objectDict setObject:object.objectId forKey:@"objectId"];
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
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnObj:nil andCallbackID:cbID];
            
            NSLog(@"Retrieve object fail.");
            
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:[BaaSParse convertPFObjectToDictionary:object] andCallbackID:cbID];
            
            NSLog(@"Retrieve object successfully.");
        }
    }];
}

- (void) getObjectsInBackground: (NSString*) className withIds:(NSArray *)objIds andCallbackID:(long) cbID {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"objectId" containedIn:objIds];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnObj:nil andCallbackID:cbID];
            
            NSLog(@"Retrieve object fail.");
        } else {
            NSMutableArray* objArr = [[NSMutableArray alloc] init];
            for (PFObject* obj : objects) {
                [objArr addObject:[BaaSParse convertPFObjectToDictionary:obj]];
            }
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:objArr andCallbackID:cbID];

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
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:[BaaSParse convertPFObjectToDictionary:parseObj] andCallbackID:cbID];
        }
    }];
}

- (void) findObjectsInBackground: (NSString*) className whereKey: (NSString*) key containedIn: (NSArray*) values  withCallbackID:(long)callbackId {
    
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:key containedIn:values];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg: [BaaSWrapper makeErrorJsonString:error] andCallbackID:callbackId];
            
            NSLog(@"Retrieve object fail.");
        } else {
            NSMutableArray* objArr = [[NSMutableArray alloc] init];
            for (PFObject* obj : objects) {
                [objArr addObject:[BaaSParse convertPFObjectToDictionary:obj]];
            }
            
            NSString *result = [ParseUtils NSArrayToNSString:objArr];
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:result andCallbackID:callbackId];
            
            NSLog(@"Retrieve object successfully.");
        }
    }];
}


- (void) findObjectInBackground: (NSString*) className whereKey: (NSString*) key equalTo: (NSString*) value    withCallbackID: (long) callbackId {
    PFQuery* query = [PFQuery queryWithClassName:className];
    [query whereKey:key equalTo:value];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:callbackId];
            NSLog(@"Retrieve object fail.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnObj:[BaaSParse convertPFObjectToDictionary:object] andCallbackID:callbackId];
            NSLog(@"Retrieve object successfully.");
        }
    }];
}


- (void) updateObjectInBackground:(NSString *)className withId:(NSString *)objId withParams:(NSDictionary *)params andCallbackID:(long) cbID {
    PFObject *object = [PFObject objectWithoutDataWithClassName:className objectId:objId];

    for (NSString* key in [params keyEnumerator]) {
        object[key] = [params objectForKey:key];
    }
    
    [object saveInBackgroundWithBlock:^(BOOL succeed, NSError* error) {
        if (succeed) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnObj:object.objectId  andCallbackID:cbID];
            
            NSLog(@"Update object succesffully.");
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];;
            
            NSLog(@"Update object fail when saving data.");
        }
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
        if (succeed) {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg:object.objectId andCallbackID:cbID];

            NSLog(@"Delete object successfully with ID: %@ ", objId);
        } else {
            [BaaSWrapper onBaaSActionResult:self withReturnCode:succeed andReturnMsg:[BaaSWrapper makeErrorJsonString:error] andCallbackID:cbID];
            
            NSLog(@"Delete object failed with ID: %@", objId);
        }
    }];
}

- (void) fetchConfigInBackground:(NSNumber*) callbackID{
    long cbID = [callbackID longValue];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (error) {
            _currentConfig = [PFConfig currentConfig];
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:false andReturnMsg:@"Fetch failed, use locally." andCallbackID:cbID];
            
            NSLog(@"Failed to fetch. Using Cached Config.");
        } else {
            _currentConfig = config;
            
            [BaaSWrapper onBaaSActionResult:self withReturnCode:true andReturnMsg:@"Fetch successfully" andCallbackID:cbID];
            
            
            NSLog(@"Yay! Config was fetched from the server.");
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

- (NSString*) getSubscribedChannels {
    PFInstallation *obj = [PFInstallation currentInstallation];
    
//    return [ParseUtils NSArrayToNSString:obj.channels];
    return [obj.channels componentsJoinedByString:@","];
}

- (void) subscribeChannels:(NSString *)channels {
    NSArray* array = [channels componentsSeparatedByString:@","];
    
    [PFInstallation currentInstallation].channels = array;
    [[PFInstallation currentInstallation] saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Subscribe succeeded to channels: %@", array);
        } else {
            NSLog(@"Subscribe failed to channels: %@ with error: %@", array, error);
        }
    }];
}

- (void) unsubscribeChannels:(NSString *)channels {
    NSArray* array = [ParseUtils NSStringToArrayOrNSDictionary:channels];
    
    NSMutableArray* subcribed = [NSMutableArray arrayWithArray:[PFInstallation currentInstallation].channels];
    
    for (int i = 0; i < array.count; i++) {
        if ([subcribed containsObject:[array objectAtIndex:i]]) {
            [subcribed removeObject:[array objectAtIndex:i]];
        }
    }

    [PFInstallation currentInstallation].channels = array;
    [[PFInstallation currentInstallation] saveEventually];
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
