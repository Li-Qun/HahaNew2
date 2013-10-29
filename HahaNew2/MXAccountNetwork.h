//
//  AccountNetwork.h
//  MxBrowser
//
//  Created by Alex Lee on 2/6/12.
//  Copyright (c) 2012 MAXTHON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXSingleton.h"
#import "ASIHTTPRequest.h"
#import "MXUser.h"

@protocol MXAccountNetworkDelegate
@optional
- (void)handleLoginResult:(NSDictionary *)info;
- (void)handleSingupResult:(NSDictionary *)info;
- (void)handleGetProfileResult:(NSDictionary *)info;
- (void)handleUploadAvatarResult:(NSDictionary *)info;
- (void)handleModifyAvatarUrlResult:(NSDictionary *)info;
- (void)handleDownloadAvatarResult:(NSDictionary *)info;
- (void)handleUpdateOnlineResult:(NSDictionary *)info;

@end


@interface MXAccountNetwork : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appId;  //eg: "mxa", "mx3" ...
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *pkgType; // intl, zh-cn;

@property (nonatomic, assign) id<MXAccountNetworkDelegate> delegate;

// 初始化
- (id) initWithVersion:(NSString *)appVersion 
                appId:(NSString *)appId 
               device:(NSString *)deviceid 
              pkgType:(NSString *)pkgType;

// 用户登陆
- (void)loginAsUser:(MXUser *)user option:(NSInteger)option;
// 用户注册
- (void)signupUser:(MXUser *)user;
// 获取用户资料
- (void)getProfile;
// 上传新头像
- (void)uploadAvatarImage:(NSData *)imageData;
// 修改用户资料
- (void)modifyAvatarUrl:(NSString *)url;
// 便于统计用户在线时间 0:开始统计， 1:维持在线统计
- (void)setOnLineStatus:(NSInteger)status;

//下载头像
- (void) downloadAvatar;

- (void) cancellAllRequest;
@end
