//
//  MXUser.m
//  MXAccount
//
//  Created by Alex Lee on 2/8/12.
//  Copyright (c) 2012 Maxthon. All rights reserved.
//

#import "MXUser.h"

@implementation MXUser
@synthesize valid,uid, userName, password, nickName, key, maxAuth/*, userHomeDirectory*/;
@synthesize avatarFilePath, avatarUrl, regionDomain, grade, onlineTime, point, status, updateTime;

- (void) dealloc
{
    self.uid = nil;
    self.userName = nil;
    self.password = nil;
    self.nickName = nil;
    self.key = nil;
    self.maxAuth = nil;
    self.avatarFilePath = nil;
    self.avatarUrl = nil;
    self.regionDomain = nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    MXUser *copy = [[self.class allocWithZone:zone] init];
    copy.valid = self.valid;
    copy.uid = self.uid;
    copy.userName = self.userName;
    copy.password = self.password;
    copy.nickName = self.nickName;
    copy.key = self.key;
    copy.maxAuth = self.maxAuth;
    copy.avatarFilePath = self.avatarFilePath;
    copy.avatarUrl = self.avatarUrl;
    copy.regionDomain = self.regionDomain;
    copy.grade = self.grade;
    copy.onlineTime = self.onlineTime;
    copy.point = self.point;
    copy.status = self.status;
    copy.updateTime = self.updateTime;
    
    return copy;
}

+ (MXUser *) userFromDictionary:(NSDictionary *)dic
{
    if (dic == nil/* || dic.count == 0*/) {
        return nil;
    }
    
    MXUser *copy = [[[MXUser alloc] init] autorelease];
    id nullObj = [NSNull null];
    
    id obj = [dic objectForKey:@"uid"];
    copy.uid = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"userName"];
    copy.userName = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"password"];
    copy.password = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"nickName"];
    copy.nickName = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"key"];
    copy.key = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"maxAuth"];
    copy.maxAuth = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"avatarFilePath"];
    copy.avatarFilePath = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"avatarUrl"];
    copy.avatarUrl = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"regionDomain"];
    copy.regionDomain = (obj == nullObj ? nil : obj);
    
    obj = [dic objectForKey:@"grade"];
    copy.grade = (obj == nullObj ? 0 : [obj integerValue]);
    
    obj = [dic objectForKey:@"onlineTime"];
    copy.onlineTime = (obj == nullObj ? 0 : [obj integerValue]);
    
    obj = [dic objectForKey:@"point"];
    copy.point = (obj == nullObj ? 0 : [obj integerValue]);
    
    obj = [dic objectForKey:@"status"];
    copy.status = (obj == nullObj ? 0 : [obj integerValue]);
    
    obj = [dic objectForKey:@"updateTime"];
    copy.updateTime = (obj == nullObj ? 0 : [obj integerValue]);
    
    return copy;
}

+ (NSDictionary *)dictionaryFromUser:(MXUser *)user
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (user.uid) {
        [dic setObject:user.uid forKey:@"uid"];
    }
    if (user.userName) {
        [dic setObject:user.userName forKey:@"userName"];
    }
    if (user.password) {
        [dic setObject:user.password forKey:@"password"];
    }
    if (user.nickName) {
        [dic setObject:user.nickName forKey:@"nickName"];
    }
    if (user.key) {
        [dic setObject:user.key forKey:@"key"];
    }
    if (user.maxAuth) {
        [dic setObject:user.maxAuth forKey:@"maxAuth"];
    }
    if (user.avatarFilePath) {
        [dic setObject:user.avatarFilePath forKey:@"avatarFilePath"];
    }
    if (user.avatarUrl) {
        [dic setObject:user.avatarUrl forKey:@"avatarUrl"];
    }
    if (user.regionDomain) {
        [dic setObject:user.regionDomain forKey:@"regionDomain"];
    }
    if (user.grade) {
        [dic setObject:[NSNumber numberWithInt:user.grade] forKey:@"grade"];
    }
    if (user.onlineTime) {
        [dic setObject:[NSNumber numberWithInt:user.onlineTime] forKey:@"onlineTime"];
    }
    if (user.point) {
        [dic setObject:[NSNumber numberWithInt:user.point] forKey:@"point"];
    }
    if (user.status) {
        [dic setObject:[NSNumber numberWithInt:user.status] forKey:@"status"];
    }
    if (user.updateTime) {
        [dic setObject:[NSNumber numberWithInt:user.updateTime] forKey:@"updateTime"];
    }

    return dic;
}

@end
