//
//  MXUser.h
//  MXAccount
//
//  Created by Alex Lee on 2/8/12.
//  Copyright (c) 2012 Maxthon_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXUser : NSObject <NSCopying>

@property (nonatomic, getter = isValid) BOOL      valid;
@property (nonatomic, copy)           NSNumber   *uid;
@property (nonatomic, copy)           NSString   *userName;
@property (nonatomic, copy)           NSString   *password;
@property (nonatomic, copy)           NSString   *nickName;
@property (nonatomic, copy)           NSString   *key;
@property (nonatomic, copy)           NSString   *maxAuth;
@property (nonatomic, copy)           NSString   *regionDomain;

@property (nonatomic, copy)           NSString   *avatarUrl;
@property (nonatomic, copy)           NSString   *avatarFilePath;
@property (nonatomic)                 NSInteger   grade;
@property (nonatomic)                 NSInteger   onlineTime;
@property (nonatomic)                 NSInteger   point;
@property (nonatomic)                 NSInteger   status;
@property (nonatomic)                 NSInteger   updateTime;

+ (MXUser *) userFromDictionary:(NSDictionary *)dic;
+ (NSDictionary *) dictionaryFromUser:(MXUser *)user;
@end