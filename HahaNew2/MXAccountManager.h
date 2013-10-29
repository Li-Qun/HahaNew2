//
//  MXAccountManager.h
//  MxBrowser
//
//  Created by Alex Lee on 2/6/12.
//  Copyright (c) 2012 MAXTHON. All rights reserved.
//

#import "MXSingleton.h"
#import "MXAccountNetwork.h"
#import "MXUser.h"

@protocol MXAccountDelegate <NSObject>

@optional
- (void) userDidLogin;
- (void) loginDidFail:(NSDictionary *) info;
- (void) handleSignupResult:(NSDictionary *)info;
- (void) userProfileDidChange;
- (void) getUserProfileDidFail;
- (void) downloadAvatarDidFail;
- (void) downloadAvatarDidFinish;
- (void) userAvatarDidUpload;
- (void) uploadUserAvatarDidFailed;
@end

typedef enum {
    MXLoginOptionNone,
    MXLoginOptionSavePassword,
    MXLoginOptionAutoLogin,
} MXLoginOption;

@interface MXAccountManager : MXSingleton <MXAccountNetworkDelegate>

@property (nonatomic, assign)           id<MXAccountDelegate>  delegate;
@property (nonatomic, readonly)         BOOL                   logingIn;//是否正在登陆



+ (MXAccountManager *) shareInstance;

- (void) initlizedWithVersion:(NSString *)appVersion 
                        appId:(NSString *)appId 
                       device:(NSString *)deviceid 
                      pkgType:(NSString *)pkgType;
//获取当前用户的copy对象
- (MXUser *) currentUser;
- (NSNumber *) currentUserId;
- (NSString *) currentUserKey;
- (NSString *) currentUserAuth;

// 当前用户是否非匿名用户
// return YES：当前用户是已登录账户(currentUser != nil)
//        NO： 当前没有已登陆用户(currentUser == nil)
- (BOOL) isCurrentUserAvaiable;

- (MXUser *) userWithUid:(NSNumber *)uid;
- (MXUser *) userWithUserName:(NSString *)userName;

- (void) autoLogin;
- (void) loginAsAccount:(NSString *)userAccount password:(NSString *)password regionDomain:(NSString *)region option:(MXLoginOption)option;
- (void) logoutAndClearUserData:(BOOL)clear;

- (void) singupAccount:(NSString *)userAccount password:(NSString *)password;

- (void) getProfile;

- (void) uploadAvatar:(NSData *) imageData;
// 启动维持用户在线状态的心跳连接 - 便于后台统计用户在线时间
// timeinterval:0 采用服务器配置的时间，
- (void) startOnLineHeartBeatTestWithMinimumDuration:(NSTimeInterval) timeinterval;
- (void) stopOnLineHeartBeatTest;

@end
