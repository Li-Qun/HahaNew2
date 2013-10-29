//
//  MXAccountManager.m
//  MxBrowser
//
//  Created by Alex Lee on 2/6/12.
//  Copyright (c) 2012 MAXTHON. All rights reserved.
//

#import "MXAccountManager.h"
#import "Utils.h"
#import "SBJson.h"
#import "NSData-AES.h"

@interface MXAccountManager()
//当前在线用户
@property (nonatomic, retain)             MXUser           *onLineUser;
@property (nonatomic, retain)             MXAccountNetwork *engine;
@property (nonatomic,         readwrite)  BOOL              logingIn;//是否正在登陆
@property (nonatomic)                     BOOL              cancelHeartBeat;//定时向服务器发送统计时长的包
@property (nonatomic, retain)             NSTimer           *heartBeatTimer;
@property (nonatomic)                     NSTimeInterval    minimumHeartBeatTime;

- (NSString *) usersConfigurationPath; 
- (MXUser *) userFromEncryptedData:(NSData *)data;
- (MXUser *) userFromConfigurationFileWithUid:(NSNumber *)uid;
- (void) writeUserDataToFile:(MXUser *)user;
- (void) writeAutoLoginUserToFile:(MXUser *)user;

@end

@implementation MXAccountManager
@synthesize delegate,logingIn;
@synthesize onLineUser, engine, cancelHeartBeat, minimumHeartBeatTime, heartBeatTimer;

//
//plist file content:
// <dic>
//     <key>autoLogin</key><NSNumber>uid</NSNumber>
//     <key>users</key>
//     <dic>
//         <key>uid</key><NSData>encrypted json data</NSData>
//     </dic>
// </dic>
//
NSString * const USERS_CONFIG_FILE = @"accounts.plist";
NSString * const USER_DATA_ENC_KEY = @"1d4ae3be5d2fead8";//do NOT changed it!

- (void) singletonDealloc
{
    self.onLineUser = nil;
    self.engine = nil;
    self.heartBeatTimer = nil;
}

+ (MXAccountManager *) shareInstance
{
    return (MXAccountManager *)[super sharedInstance];
}

- (MXUser *) currentUser
{
    return [[self.onLineUser copy] autorelease];
}

- (NSNumber *) currentUserId
{
    return self.onLineUser.uid;
}
- (NSString *) currentUserKey
{
    return self.onLineUser.key;
}
- (NSString *) currentUserAuth
{
    return self.onLineUser.maxAuth;
}


- (void) initlizedWithVersion:(NSString *)appVersion 
                        appId:(NSString *)appId 
                       device:(NSString *)deviceid 
                      pkgType:(NSString *)pkgType
{
    MXAccountNetwork *myEngine = [[MXAccountNetwork alloc] initWithVersion:appVersion appId:appId device:deviceid pkgType:pkgType];
    myEngine.delegate = self;
    self.engine = myEngine;
    [myEngine release];
}

- (NSString *) usersConfigurationPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documemtPath = [paths objectAtIndex:0];
    NSString *userConfigPath = [documemtPath stringByAppendingPathComponent:@".accounts"];
    NSError *error;
    if(![[NSFileManager defaultManager] createDirectoryAtPath:userConfigPath withIntermediateDirectories:YES attributes:nil error:&error]){
        MXLogError(error);
        MXAssertDebug(YES, "create path:[%@] failed!!!", userConfigPath);
    }
    return userConfigPath;
}

- (MXUser *) userFromEncryptedData:(NSData *)encryptionData
{
    NSData *decryptedData = [encryptionData AESDecryptWithPassphrase:USER_DATA_ENC_KEY];    
    NSString *jsonStr = [[NSString alloc]initWithData:decryptedData encoding:NSUTF8StringEncoding];
    NSString *userJsonStr = nil;
    NSRange range = [jsonStr rangeOfString:@"\0"];
    if (range.location != NSNotFound) {
        userJsonStr = [jsonStr substringToIndex:range.location];
    } else {
        userJsonStr = [NSString stringWithString:jsonStr];
    }
    [jsonStr release];
    
    //NSString *jsonStr = [[userConfigs objectForKey:@"users"] objectForKey:[uid stringValue]];
    id userDic = [userJsonStr JSONValue];
    MXUser *user = [MXUser userFromDictionary:userDic];
    return user;
}

- (MXUser *) userFromConfigurationFileWithUid:(NSNumber *)uid
{
    NSString *configFile = [[self usersConfigurationPath] stringByAppendingPathComponent:USERS_CONFIG_FILE];
    NSDictionary *userConfigs = [NSDictionary dictionaryWithContentsOfFile:configFile];
    NSData *encryptionData = [[userConfigs objectForKey:@"users"] objectForKey:[uid stringValue]];
    
    return [self userFromEncryptedData:encryptionData];
}

- (void) writeUserDataToFile:(MXUser *)user
{
    if (user.uid != nil) {
        NSDictionary *userDic = [MXUser dictionaryFromUser:user];
        NSString *jsonStr = [userDic JSONRepresentation];
        //MXLog(@"user to json:%@", jsonStr);
        NSData *data = [jsonStr dataUsingEncoding: NSUTF8StringEncoding];
        NSData *encryptedData = [data AESEncryptWithPassphrase:USER_DATA_ENC_KEY];
        
        NSString *configFile = [[self usersConfigurationPath] stringByAppendingPathComponent:USERS_CONFIG_FILE];
        NSMutableDictionary *userConfigs = [NSMutableDictionary dictionaryWithContentsOfFile:configFile];
        if (userConfigs == nil) {
            userConfigs = [NSMutableDictionary dictionary];
        }
        NSMutableDictionary *users = [userConfigs objectForKey:@"users"];
        if (users == nil) {
            users = [NSMutableDictionary dictionary];
            [userConfigs setObject:users forKey:@"users"];
        }
        [users setValue:encryptedData forKey:[user.uid stringValue]];
        
        [userConfigs writeToFile:configFile atomically:YES];
    }
}

// user==nil or user.uid == nil will clear the autologin data;
- (void) writeAutoLoginUserToFile:(MXUser *)user
{
    NSString *configFile = [[self usersConfigurationPath] stringByAppendingPathComponent:USERS_CONFIG_FILE];
    NSMutableDictionary *userConfigs = [NSMutableDictionary dictionaryWithContentsOfFile:configFile];

    if (user.uid != nil) {
        if (userConfigs == nil) {
            userConfigs = [NSMutableDictionary dictionary];
        }
        NSNumber *autoLoginUser = [userConfigs objectForKey:@"autoLogin"];
        if (![autoLoginUser isEqualToNumber:user.uid]) {
            [userConfigs setObject:user.uid forKey:@"autoLogin"];
        }
    } else {
        [userConfigs removeObjectForKey:@"autoLogin"];
    }
    [userConfigs writeToFile:configFile atomically:YES];
} 

#pragma mark -
- (BOOL) isCurrentUserAvaiable
{
    return self.onLineUser != nil;
}

- (MXUser *) userWithUid:(NSNumber *)uid
{
    return [self userFromConfigurationFileWithUid:uid];
}
- (MXUser *) userWithUserName:(NSString *)userName
{
    NSString *configFile = [[self usersConfigurationPath] stringByAppendingPathComponent:USERS_CONFIG_FILE];
    NSDictionary *users = [[NSDictionary dictionaryWithContentsOfFile:configFile] objectForKey:@"users"];
    for (NSData *encryptedData in users.objectEnumerator) {
        MXUser *user = [self userFromEncryptedData:encryptedData];
        if ([user.userName isEqualToString:userName]) {
            return user;
        }
    }
    return nil;
}

#pragma mark - login
- (void) autoLogin
{
    if (self.logingIn) {
        return;
    }
    [self stopOnLineHeartBeatTest];
    [self.engine cancellAllRequest];
    
    NSString *configFile = [[self usersConfigurationPath] stringByAppendingPathComponent:USERS_CONFIG_FILE];
    NSMutableDictionary *userConfigs = [NSMutableDictionary dictionaryWithContentsOfFile:configFile];
    NSNumber *autoLoginUid = [userConfigs objectForKey:@"autoLogin"];
    MXUser *user = [self userFromConfigurationFileWithUid:autoLoginUid];

    if (autoLoginUid != nil && [user.uid isEqualToNumber:autoLoginUid]) {//for security
        [self.engine loginAsUser:user option:MXLoginOptionNone];
    }
}

- (void) logoutAndClearUserData:(BOOL)clear
{
    [self stopOnLineHeartBeatTest];// 注销操作，
    self.onLineUser = nil;
    [self writeAutoLoginUserToFile:nil]; //remove auto login config;
    //???: 注销操作， 等同于登录到默认账号
    if ([self.delegate respondsToSelector:@selector(userDidLogin)]) {
        [self.delegate userDidLogin];
    }
    NSArray *cookies =[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.domain isEqualToString:@".maxthon.cn"] ||
            [cookie.domain isEqualToString:@".maxthon.com"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
    }
    
}

- (void) loginAsAccount:(NSString *)userAccount password:(NSString *)password regionDomain:(NSString *)region option:(MXLoginOption)option
{
    MXParameterAssert(!isEmptyString(userAccount));
    MXParameterAssert(!isEmptyString(password));
    
    if (self.logingIn) {
        return;
    }
    [self stopOnLineHeartBeatTest];
    [self.engine cancellAllRequest];
    
    MXUser *user = [self userWithUserName:userAccount];
    if (user == nil) {
        user = [[[MXUser alloc] init] autorelease];
    }
    user.userName = userAccount;
    user.password = password;
    if (region != nil) {
        user.regionDomain = region;
    }
    [self.engine loginAsUser:user option:option];
}

- (void) handleLoginResult:(NSDictionary *)info
{
    if ([[info valueForKey:@"result"] boolValue]) 
    {
        NSString *responseString = [info objectForKey:@"responseData"];
        NSDictionary *jsonDict = [responseString JSONValue];
        NSNumber *result = [jsonDict valueForKey:@"result"];    
        if ([result intValue] == 1){ // login success
            MXUser *user = [info objectForKey:@"user"];
            user.valid = YES;
            user.key = [jsonDict valueForKey:@"key"];
            user.maxAuth = [jsonDict valueForKey:@"maxauth"];
            user.uid = [jsonDict valueForKey:@"user_id"];
            
            NSString *domain = [jsonDict valueForKey:@"region_domain"];
            if(!isEmptyString(domain)){
                user.regionDomain = domain;
            }
            self.onLineUser = user;
            
            MXLoginOption option = [[info valueForKey:@"option"] integerValue];
            if (option != MXLoginOptionNone)
            {
                [self writeUserDataToFile:user];
            }
            if (option == MXLoginOptionAutoLogin)
            {
                [self writeAutoLoginUserToFile:user];
            }
            self.logingIn = NO;
            //set cookies;
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:
             [NSHTTPCookie cookieWithProperties:
              [NSDictionary dictionaryWithObjectsAndKeys:
               user.maxAuth, NSHTTPCookieValue,
               @"MAXAUTH", NSHTTPCookieName,
               @".haha.mx", NSHTTPCookieDomain,
               @"/", NSHTTPCookiePath,
               [NSNumber numberWithInt:3600 * 24 * 30], NSHTTPCookieMaximumAge,
               nil]]];
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:
//            [NSHTTPCookie cookieWithProperties:
//             [NSDictionary dictionaryWithObjectsAndKeys:
//              user.maxAuth, NSHTTPCookieValue,
//              @"MAXAUTH", NSHTTPCookieName,
//              @".maxthon.com", NSHTTPCookieDomain,
//              @"/", NSHTTPCookiePath,
//              [NSNumber numberWithInt:3600 * 24 * 30], NSHTTPCookieMaximumAge, 
//              nil]]];            
        
            if ([self.delegate respondsToSelector:@selector(userDidLogin)])
            {
                [self.delegate userDidLogin];
            }
            
        } 
        else 
        {
            if ([self.delegate respondsToSelector:@selector(loginDidFail:)]) 
            {
                [self.delegate loginDidFail:[NSDictionary dictionaryWithObjectsAndKeys:
                                          result, @"errorCode", 
                                          [jsonDict valueForKey:@"message"], @"errorMessage", 
                                          nil]];
            }
        }
    } 
    else 
    { // network error
        if ([self.delegate respondsToSelector:@selector(loginDidFail:)]) 
        {
            [self.delegate loginDidFail:[NSDictionary dictionaryWithObjectsAndKeys:
                                      @"Network Error", @"errorMessage", 
                                      nil]];
        }
    }
}

#pragma mark - singup
- (void) singupAccount:(NSString *)userAccount password:(NSString *)password {
    MXParameterAssert(!isEmptyString(userAccount));
    MXParameterAssert(!isEmptyString(password));
    
    MXUser *user = [[[MXUser alloc] init] autorelease];
    user.userName = userAccount;
    user.password = password;
    [self.engine signupUser:user];
}

- (void) handleSingupResult:(NSDictionary *)info
{
	if ([[info objectForKey:@"result"] boolValue]) {
        NSString *responseString = [info objectForKey:@"responseData"];
        
        NSDictionary *jsonDict = [responseString JSONValue];
        NSNumber *code = [jsonDict valueForKey:@"code"]; //0:1
        NSString *msg = [jsonDict valueForKey:@"msg"];
        
        if([code intValue] == 0) {//注册成功
            MXUser *user = [info objectForKey:@"user"];
            user.uid = [jsonDict valueForKey:@"id"];
            if ([self.delegate respondsToSelector:@selector(handleSignupResult:)]) {
                [self.delegate handleSignupResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithBool:YES], @"result", 
                                                   user, @"user",
                                                   nil]];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(handleSignupResult:)]) {
                [self.delegate handleSignupResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithBool:NO], @"result", 
                                                   msg, @"errorMessage",
                                                   nil]];
            }
        }
    }
    else 
    {
        if ([self.delegate respondsToSelector:@selector(handleSignupResult:)]) {
            [self.delegate handleSignupResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:NO], @"result", 
                                               @"Network Error", @"errorMessage",
                                               nil]];
        }
    }
}

#pragma mark - get profile
- (void) getProfile
{
    [self.engine getProfile];
}

- (void) handleGetProfileResult:(NSDictionary *)info
{
    NSNumber *uid = [info objectForKey:@"uid"];
    if ([self isCurrentUserAvaiable] && [uid isEqualToNumber:self.onLineUser.uid]) {
        if ([[info objectForKey:@"result"] boolValue]){
            NSString *responseString = [info objectForKey:@"responseData"];
            NSDictionary *jsonDict = [responseString JSONValue];
            
            NSString *avatarUrl = [jsonDict objectForKey:@"Avatarurl"];
            BOOL avatarChanged = NO;
            if (!isEmptyString(avatarUrl) && ![avatarUrl isEqualToString:self.onLineUser.avatarUrl]) {
                avatarChanged = YES;
            } else if (isEmptyString(self.onLineUser.avatarFilePath)) {
                avatarChanged = YES;
            } else if (![[NSFileManager defaultManager] fileExistsAtPath:self.onLineUser.avatarFilePath]) {
                avatarChanged = YES;
            }
            
            self.onLineUser.avatarUrl = avatarUrl;
            self.onLineUser.grade = [[jsonDict objectForKey:@"Grade"] integerValue];
            self.onLineUser.onlineTime = [[jsonDict objectForKey:@"OnlineTime"] integerValue];
            self.onLineUser.point = [[jsonDict objectForKey:@"Point"] integerValue];
            self.onLineUser.status = [[jsonDict objectForKey:@"Status"] integerValue];
            self.onLineUser.updateTime = [[jsonDict objectForKey:@"UpdateTime"] integerValue];
            self.onLineUser.nickName = [jsonDict objectForKey:@"Nickname"];
            
            if (avatarChanged) {
                [[NSFileManager defaultManager] removeItemAtPath:self.onLineUser.avatarFilePath error:NULL];
                self.onLineUser.avatarFilePath = nil;
                [self writeUserDataToFile:self.onLineUser];
                [self.engine downloadAvatar];
            }
            if ([self.delegate respondsToSelector:@selector(userProfileDidChange)]) {
                [self.delegate userProfileDidChange];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(getUserProfileDidFail)]) {
                [self.delegate getUserProfileDidFail];
            }
        } 
    }
}


- (void) handleDownloadAvatarResult:(NSDictionary *)info
{
    NSNumber *uid = [info objectForKey:@"uid"];
	if ([[info objectForKey:@"result"] boolValue]) { 
        NSString *urlString = [info objectForKey:@"avatarUrl"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *avatarFile = [[self usersConfigurationPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"avatar_%@", [uid stringValue]]];
        NSString *extension = [url pathExtension];
        if (!isEmptyString(extension)) {
            avatarFile = [avatarFile stringByAppendingPathExtension:extension];
        }
        NSData *imageData = [info objectForKey:@"responseData"];
        if ([imageData writeToFile:avatarFile atomically:YES]) {
            MXUser *user = [self userFromConfigurationFileWithUid:uid];
            if (user != nil) {
                if ([self isCurrentUserAvaiable] && [user.uid isEqualToNumber:self.onLineUser.uid]) {
                    self.onLineUser.avatarFilePath = avatarFile;
                    [self writeUserDataToFile:self.onLineUser];
                }
                else {
                    user.avatarFilePath = avatarFile;
                    [self writeUserDataToFile:user];
                }
            }
        } 
        if ([self isCurrentUserAvaiable] && [uid isEqualToNumber:self.onLineUser.uid] &&
             [self.delegate respondsToSelector:@selector(downloadAvatarDidFinish)]) {
            [self.delegate downloadAvatarDidFinish];
        }
    } else {
        if ([self isCurrentUserAvaiable] && [uid isEqualToNumber:self.onLineUser.uid] &&
             [self.delegate respondsToSelector:@selector(downloadAvatarDidFail)]) {
            [self.delegate downloadAvatarDidFail];
        }
    }
}

#pragma mark - modify avatar
- (void) uploadAvatar:(NSData *)imageData
{
    [self.engine uploadAvatarImage:imageData];
}

- (void) handleUploadAvatarResult:(NSDictionary *)info
{
    BOOL hasError = YES;
    if ([[info objectForKey:@"result"] boolValue]) {
        if ([self isCurrentUserAvaiable] && [[info objectForKey:@"uid"] isEqualToNumber:self.onLineUser.uid]) {
            NSString *responseString = [info objectForKey:@"responseData"];
            
            NSDictionary *jsonDict = [responseString JSONValue];
            NSNumber *code = [jsonDict valueForKey:@"code"]; //0:1            
            if([code intValue] == 0) {//上传成功
                NSString *avatar_link = [jsonDict valueForKey:@"avatar_link"];
                [self.engine modifyAvatarUrl:avatar_link];
                hasError = NO;
            } 
        } else {
            hasError = NO;
        }
    }
    if (hasError) {
        if ([self.delegate respondsToSelector:@selector(uploadUserAvatarDidFailed)]) {
            [self.delegate uploadUserAvatarDidFailed];
        }
    }
}

- (void) handleModifyAvatarUrlResult:(NSDictionary *)info
{
    BOOL hasError = YES;
    if ([[info objectForKey:@"result"] boolValue]) {
        if ([self isCurrentUserAvaiable] && [[info objectForKey:@"uid"] isEqualToNumber:self.onLineUser.uid]) {
            NSString *responseString = [info objectForKey:@"responseData"];
            NSDictionary *jsonDict = [responseString JSONValue];
            NSNumber *code = [jsonDict valueForKey:@"code"]; //0:1
            
            if([code intValue] == 0) {//上传成功
                if ([self.delegate respondsToSelector:@selector(userAvatarDidUpload)]) {
                    [self.delegate userAvatarDidUpload];
                }
                //self.onLineUser.avatarUrl = [info objectForKey:@"AvatarUrl"];
                [self.engine getProfile];
                hasError = NO;
            }
        } else {
            hasError = NO;
        }
    }
    if (hasError) {
        if ([self.delegate respondsToSelector:@selector(uploadUserAvatarDidFailed)]) {
            [self.delegate uploadUserAvatarDidFailed];
        }
    }
}

#pragma mark - heart beat test
- (void) startOnLineHeartBeatTestWithMinimumDuration:(NSTimeInterval)timeinterval {
    if (self.onLineUser) {
        self.cancelHeartBeat = NO;
        self.minimumHeartBeatTime = timeinterval;
        [self.engine setOnLineStatus:0];//first heart beat
    }
}
- (void) stopOnLineHeartBeatTest
{
    self.cancelHeartBeat = YES;
    if ([self.heartBeatTimer isValid]) {
        [self.heartBeatTimer invalidate];
    }
    self.heartBeatTimer = nil;
}

- (void) handleHeartBeatTimer:(NSTimer *)timer
{
    [self.engine setOnLineStatus:1]; // not first heart beat
}

- (void) handleUpdateOnlineResult:(NSDictionary *)info
{
    NSString *responseString = [info objectForKey:@"responseData"];
    NSDictionary *jsonDict = [responseString JSONValue];
    
    if([[jsonDict objectForKey:@"result"] intValue])
    {
        double serverTime = [[jsonDict objectForKey:@"time_interval"] doubleValue] * 60;
        double timeinterval = MAX(self.minimumHeartBeatTime, serverTime);
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:timeinterval 
                                                               target:self 
                                                             selector:@selector(handleHeartBeatTimer:) 
                                                             userInfo:nil 
                                                              repeats:NO];
    }
}

@end
