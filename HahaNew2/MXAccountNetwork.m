//
//  AccountNetwork.m
//  MxBrowser
//
//  Created by Alex Lee on 2/6/12.
//  Copyright (c) 2012 MAXTHON. All rights reserved.
//

#import "MXAccountNetwork.h"
#import "MXAccountManager.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "NSData-AES.h"
#import "Base64.h"
#import "Utils.h"

typedef enum
{
    AccountRequestLogin,
	AccountRequestRegister,
	AccountRequestProfileInfo,
	AccountRequestUploadAvatar,
    AccountRequestModifyProfile,
    AccountRequestUpdateUserStatus,
    AccountRequestDownloadAvata	
}MXAccountRequestTag;

@interface MXAccountNetwork()
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (nonatomic, retain) NSRecursiveLock *queueLock;

- (void) checkParameters;
- (NSData *) generateRequestBody: (NSString *) json;
- (NSString *) extractResponse:(ASIHTTPRequest *)request;
- (void) sendRequest:(ASIHTTPRequest *)request;
@end

@implementation MXAccountNetwork
@synthesize delegate;
@synthesize appId, appVersion, deviceId, pkgType;
@synthesize networkQueue, queueLock;

//是否加密,0不加密,1加密
const int ENC = 1;
//AES加密KEY
NSString * const ENC_KEY = @"eu3o4[r04cml4eir";


- (void) dealloc
{
    self.appId = nil;
    self.appVersion = nil;
    self.deviceId = nil;
    self.pkgType = nil;
    //[self.networkQueue reset];
    self.networkQueue = nil;
    self.queueLock = nil;
    
    [super dealloc];
}

#pragma mark -
- (id) initWithVersion:(NSString *)theAppVersion 
                 appId:(NSString *)theAppId 
                device:(NSString *)theDeviceid 
               pkgType:(NSString *)thePkgType
{
    self = [super init];
    if (self) {
        self.appVersion = theAppVersion;
        self.appId = theAppId;
        self.deviceId = theDeviceid;
        self.pkgType = thePkgType;
        
        NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
        self.queueLock = lock;
        [lock release];
    }
    return self;
}

- (void) sendRequest:(ASIHTTPRequest *)request
{
    [self.queueLock lock];
    @try {
        if (!self.networkQueue) {
            self.networkQueue = [ASINetworkQueue queue];
            [self.networkQueue setShowAccurateProgress:YES];
            [self.networkQueue setShouldCancelAllRequestsOnFailure:NO];
            //[[self networkQueue] setMaxConcurrentOperationCount:5];
            [self.networkQueue reset];
        }
        [self.networkQueue addOperation:request];
        if ([self.networkQueue isSuspended]) {
            [self.networkQueue go];
        }
    }
    @finally {
        [self.queueLock unlock];
    }

}

#pragma mark - account protocol -
- (void)loginAsUser:(MXUser *)user option:(NSInteger)option
{
    MXParameterAssert(!isEmptyString(user.userName) && !isEmptyString(user.password));
    
    [self checkParameters];
    if (isEmptyString(user.regionDomain)) {
        NSString *preferredLang = [Utils userPreferredLanguage];
        user.regionDomain = [preferredLang isEqualToString:@"zh-Hans"] ? @"cn" : @"com";
    }
    NSString *url = [NSString stringWithFormat:@"http://login.user.maxthon.%@/login2", user.regionDomain]; 
    
    NSString *json = [[NSString alloc] initWithFormat:
                      @"{\"app\":\"%@\","
                      "\"ver\":\"%@\","
                      "\"device\":\"%@\","
                      "\"product_type\":\"%@\","
                      "\"password\":\"%@\","
                      "\"account\":\"%@\"}", 
                      self.appId,
                      self.appVersion,
                      self.deviceId,
                      self.pkgType,
                      [Utils SHA256Encode:user.password],
                      user.userName];
    MXLog(@"json:%@", json);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Charset" value:@"UTF-8"];
    [request addRequestHeader:@"Connection" value:@"Keep-Alive"];
    [request addRequestHeader:@"Content-Type" value:@"application/octet-stream"];

    //[self request:request postData:json forUser:nil requestTag:AccountRequestLogin];
    [request setRequestMethod:@"POST"];
    NSData *AESdata = [self generateRequestBody:json];   
    //NSString* Base64String = [Base64 encode:AESdata];    
    //[request addPostValue:AESdata forKey:@"data"];
    [request appendPostData:AESdata];
    
    request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestLogin], @"AccountRequest",
                        user, @"user",
                        [NSNumber numberWithInteger:option], @"option",
                        nil];	
	[self sendRequest:request];
}

- (void)signupUser:(MXUser *)user
{
    [self checkParameters];
    
    NSString * preferredLang = [Utils userPreferredLanguage];
    user.regionDomain = ([preferredLang isEqualToString:@"zh-Hans"])? @"cn":@"com";
    NSString *url = [NSString stringWithFormat:@"http://profile-api.user.maxthon.%@/register", user.regionDomain]; 
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	[request addPostValue:user.userName forKey:@"email"];
	[request addPostValue:user.password forKey:@"password"];
	[request addPostValue:self.appId forKey:@"app"];
	[request addPostValue:self.deviceId forKey:@"device"];
    [request setRequestMethod:@"POST"];
    
	request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestRegister], @"AccountRequest",
                        user, @"user",
                        nil];	
	[self sendRequest:request];
}

- (NSString *) urlEncode:(NSString *)src
{
    const CFStringRef legalURLCharactersToBeEscaped = CFSTR("!*'();:@&=+$,/?#[]<>\"{}|\\`^% ");
    
    return [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)src, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8)) autorelease];
}

- (void)getProfile
{
    [self checkParameters];
    
    MXUser *user = [[MXAccountManager shareInstance] onLineUser];
    NSString *url = [NSString stringWithFormat:@"http://profile.user.maxthon.%@/mx3/query", user.regionDomain]; 
    MXLog(@"%@", url);
	NSString *json = [[NSString alloc]initWithFormat:
                      @"{\"user_id\":%@," //uid
                      "\"app\":\"%@\","   //app
                      "\"device\":\"%@\","//device
                      "\"key\":\"%@\"}",  //key
                      user.uid, 
                      self.appId, 
                      self.deviceId, 
                      user.key];  
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *AESdata = [self generateRequestBody:json];   
    NSString* Base64String = [Base64 encode:AESdata];     
    NSString* URLEncodeString = [NSString stringWithFormat:@"data=%@", [self urlEncode:Base64String]];
    NSData *data = [URLEncodeString dataUsingEncoding:NSUTF8StringEncoding];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request appendPostData:data];
    request.delegate = self;

	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestProfileInfo], @"AccountRequest",
                        user.uid, @"uid",
                        nil];	
	[self sendRequest:request];
}

- (void)uploadAvatarImage:(NSData *)imageData
{
    [self checkParameters];
    
    MXUser *user = [[MXAccountManager sharedInstance] onLineUser];
    NSString *url = [NSString stringWithFormat:@"http://profile-api.user.maxthon.%@/uploadavatar", (isEmptyString(user.regionDomain) ? @"cn" : user.regionDomain)]; 
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    //NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSString* Base64String = [Base64 encode:imageData]; 
    NSMutableString *imageString = [NSMutableString stringWithFormat:@"%@,%@",@"data:image/jpg;base64", Base64String];
    [request addPostValue:imageString forKey:@"avatar_file"];
    [request addPostValue:user.uid forKey:@"uid"];
    [request addPostValue:user.key forKey:@"hashkey"];
    [request addPostValue:self.deviceId forKey:@"device"];
    [request addPostValue:self.appId forKey:@"app"];
	request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestUploadAvatar], @"AccountRequest",
                        user.uid, @"uid",
                        nil];
	[self sendRequest:request];
}

- (void)modifyAvatarUrl:(NSString *)avatarUrl
{
    [self checkParameters];
    
    MXUser *user = [[MXAccountManager sharedInstance] onLineUser];
    NSString *url = [NSString stringWithFormat:@"http://profile-api.user.maxthon.%@/modify", (isEmptyString(user.regionDomain) ? @"cn" : user.regionDomain)]; 
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"Application/octet-stream"];
    [request addPostValue:avatarUrl forKey:@"avatar_link"];
	[request addPostValue:user.uid forKey:@"uid"];
    [request addPostValue:user.key forKey:@"hashkey"];
	[request addPostValue:self.appId forKey:@"app"];
	[request addPostValue:self.deviceId forKey:@"device"];
	request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestModifyProfile], @"AccountRequest", 
                        avatarUrl, @"AvatarUrl",
                        user.uid, @"uid",
                        nil];
	[self sendRequest:request];
}

- (void)setOnLineStatus:(NSInteger)status
{
    [self checkParameters];
    
    MXUser *user = [[MXAccountManager sharedInstance] onLineUser];
    NSString *url = [NSString stringWithFormat:@"http://online.user.maxthon.%@/set", (isEmptyString(user.regionDomain) ? @"cn" : user.regionDomain)]; 
    NSString *json = [[NSString alloc]initWithFormat:
                      @"{\"user_id\":%@,"     //uid
                      "\"key\":\"%@\","       //key
                      "\"app\":\"%@\","       //app
                      "\"device\":\"%@\","    //device
                      "\"ver\":\"%@\","       //ver
                      "\"status\":%d}",       //status
                      user.uid, 
                      user.key, 
                      self.appId,
                      self.deviceId,
                      self.appVersion,
                      status];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[json dataUsingEncoding: NSUTF8StringEncoding]];
    
    request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestUpdateUserStatus], @"AccountRequest",
                        [[MXAccountManager sharedInstance] currentUserId], @"uid",
                        nil];
    
    [self sendRequest:request];
}


#pragma mark - 
- (void) downloadAvatar
{
    MXUser *user = [[MXAccountManager sharedInstance] onLineUser];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:user.avatarUrl]];
	request.requestMethod = @"GET";
	request.delegate = self;
	request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:AccountRequestDownloadAvata], @"AccountRequest", 
						user.uid, @"uid",
                        user.avatarUrl, @"avatarUrl",
                        nil];	
    [self sendRequest:request];
}


#pragma mark - private methods -
- (void) checkParameters
{
    MXParameterAssert(!isEmptyString(self.appVersion));
    MXParameterAssert(!isEmptyString(self.appId));
    MXParameterAssert(!isEmptyString(self.deviceId));
    if (isEmptyString(self.pkgType)) {
        self.pkgType = @"intl";
    }
}

- (NSData *) generateRequestBody: (NSString *) json
{
    NSMutableData *body = [NSMutableData dataWithCapacity:100];
    NSString *start = [NSString stringWithFormat:@"ENC:%d\r\n\r\n",ENC];
    [body appendData:[start dataUsingEncoding: NSUTF8StringEncoding]];
    
    switch (ENC) {
        case 0: // 不加密
            [body appendData:[json dataUsingEncoding: NSUTF8StringEncoding]];
            break;
        case 1: // AES加密
        {
            NSData *data = [json dataUsingEncoding: NSUTF8StringEncoding];
            NSData *encryptedData = [data AESEncryptWithPassphrase:ENC_KEY];
            NSString* t=[NSString stringWithCString:[encryptedData bytes] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",t);
            [body appendData:encryptedData];
        }
            break;
        default:
            break;
    }
    return body;
} // end of method generateRequestBody

//获取response body中的自定义头信息
- (NSDictionary *) mxHeadersFromHeadersData:(NSData *)headersData
{
    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    NSString *headerString = [[NSString alloc] initWithData:headersData encoding:NSUTF8StringEncoding];
    NSArray *headers = [headerString componentsSeparatedByString:@"\r\n"];
    for (NSString *str in headers) {
        NSArray *headerKV = [str componentsSeparatedByString:@":"];
        if (headerKV.count >= 2) {
            NSString *key = [[headerKV objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *val = [[headerKV objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [headerDic setObject:val forKey:key];
        }
    }
    [headerString release];
    return headerDic;
}

- (NSString *) extractResponse:(ASIHTTPRequest *)request
{
    NSString *ret = nil;
    if (![request error]) {
        NSData *data = [request responseData];
        
        NSData *search = [@"\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding] ;
        NSRange ran = NSMakeRange(0, [data length]);
        NSRange headerRange = [data rangeOfData:search options:NSDataSearchBackwards range:ran];
        
        if(headerRange.location != NSNotFound) {
            NSDictionary *headers = [self mxHeadersFromHeadersData:[data subdataWithRange:NSMakeRange(0, headerRange.location)]];
            
            NSInteger bodyLocation = headerRange.location + headerRange.length;
            NSData *encryted = [data subdataWithRange:NSMakeRange(bodyLocation, data.length - bodyLocation)];
            NSString *enc = [headers objectForKey:@"ENC"];     
            if([enc isEqualToString:@"0"]){
                ret = [[NSString alloc] initWithData:encryted encoding:NSUTF8StringEncoding];
            } else if([enc isEqualToString:@"1"]){
                NSData *decryptedData = [encryted AESDecryptWithPassphrase:ENC_KEY];
                ret = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
            }
        } else {
            MXAssertDebug(YES, @"invalid response data!!!");
        }
    } else {
        MXLog(@"%@",[[request error] localizedDescription]);
    }
    
    return [ret autorelease];
} // end of method extractResponse

#pragma mark ASIHTTPRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self.queueLock lock];
    @try {
        if ([self.networkQueue requestsCount] == 0) 
        {
            //[self.networkQueue reset];
            self.networkQueue = nil;
        }
    }
    @finally {
        [self.queueLock unlock];
    }

    MXLog(@"request url:%@", [request.url absoluteString]);
	//MXLog(@"request responseString:%@",[request responseString]);
	NSDictionary *requestInfo = [request userInfo];    
    MXAccountRequestTag requestTag = [[requestInfo objectForKey:@"AccountRequest"] intValue];
    
    if (AccountRequestLogin == requestTag) {
        NSString *stringData = [self extractResponse:request];
        NSRange range = [stringData rangeOfString:@"\0"];
        if (range.location != NSNotFound) {
            stringData = [stringData substringToIndex:range.location];
        }
        MXLog(@"response:%@", stringData);
        [self.delegate handleLoginResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:YES], @"result", 
                                          stringData, @"responseData",
                                          [requestInfo objectForKey:@"user"], @"user",
                                          [requestInfo objectForKey:@"option"], @"option",
                                          nil]];
    }
    else if (AccountRequestProfileInfo == requestTag) {
        NSString *stringData = [self extractResponse:request];
        NSRange range = [stringData rangeOfString:@"\0"];
        if (range.location != NSNotFound) {
             stringData = [stringData substringToIndex:range.location];
        }
        MXLog(@"response:%@", stringData);
        [self.delegate handleGetProfileResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES], @"result", 
                                               stringData, @"responseData",
                                               [requestInfo objectForKey:@"uid"], @"uid",
                                               nil]];
    }
    else if (AccountRequestRegister == requestTag) {
        NSString *stringData = [request responseString];
        MXLog(@"response:%@", stringData);
        [self.delegate handleSingupResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithBool:YES], @"result",
                                           stringData, @"responseData",
                                           [requestInfo objectForKey:@"user"], @"user",
                                           nil]];
    }
    else if (AccountRequestModifyProfile == requestTag) {
        NSString *stringData = [request responseString];
        MXLog(@"response:%@", stringData);
        [self.delegate handleModifyAvatarUrlResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithBool:YES], @"result",
                                                    stringData, @"responseData",
                                                    [requestInfo objectForKey:@"AvatarUrl"], @"AvatarUrl", 
                                                    [requestInfo objectForKey:@"uid"], @"uid",
                                                    nil]];
    }
    else if (AccountRequestUpdateUserStatus == requestTag) {
        NSString *stringData = [request responseString];
        MXLog(@"response:%@", stringData);
        [self.delegate handleUpdateOnlineResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES], @"result",
                                                 stringData, @"responseData",
                                                 [requestInfo objectForKey:@"uid"], @"uid",
                                                 nil]];
    }
    else if (AccountRequestUploadAvatar == requestTag) {
        NSString *stringData = [request responseString];
        MXLog(@"response:%@", stringData);
        [self.delegate handleUploadAvatarResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES], @"result",
                                                 stringData, @"responseData",
                                                 [requestInfo objectForKey:@"uid"], @"uid",
                                                 nil]];
    }
    else if (AccountRequestDownloadAvata == requestTag) {
        NSData *avatar = [request responseData];
        [self.delegate handleDownloadAvatarResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithBool:YES], @"result",
                                                   [requestInfo objectForKey:@"uid"], @"uid",
                                                   [requestInfo objectForKey:@"avatarUrl"], @"avatarUrl",
                                                   avatar, @"responseData",
                                                   nil]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.queueLock lock];
    @try {
        if ([self.networkQueue requestsCount] == 0) 
        {
            //[self.networkQueue reset];
            self.networkQueue = nil; 
        }
    }
    @finally {
        [self.queueLock unlock];
    } 	
    NSDictionary *requestInfo = [request userInfo];
    MXAccountRequestTag requestTag = [[requestInfo objectForKey:@"AccountRequest"] intValue];
    NSError *error = request.error;
    MXLog(@"request url:%@", [request.url absoluteString]);
    MXLogError(error);
    if (AccountRequestLogin == requestTag) {
        [self.delegate handleLoginResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:NO], @"result", 
                                          error, @"error",
                                          nil]];
    }
    else if (AccountRequestProfileInfo == requestTag) {
        [self.delegate handleGetProfileResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES], @"result", 
                                               error, @"error",
                                               [requestInfo objectForKey:@"uid"], @"uid",
                                               nil]];
    }
    else if (AccountRequestRegister == requestTag) {        
        [self.delegate handleSingupResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithBool:YES], @"result",
                                           error, @"error",
                                           nil]];
    }
    else if (AccountRequestModifyProfile == requestTag) {        
        [self.delegate handleModifyAvatarUrlResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithBool:YES], @"result",
                                                  error, @"error",
                                                  [requestInfo objectForKey:@"uid"], @"uid",
                                                  nil]];
    }
    else if (AccountRequestUpdateUserStatus == requestTag) {        
        [self.delegate handleUpdateOnlineResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES], @"result",
                                                 error, @"error",
                                                 [requestInfo objectForKey:@"uid"], @"uid",
                                                 nil]];
    }
    else if (AccountRequestUploadAvatar == requestTag) {
        [self.delegate handleUploadAvatarResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithBool:YES], @"result",
                                                 error, @"error",
                                                 [requestInfo objectForKey:@"uid"], @"uid",
                                                 nil]];
    }
    else if (AccountRequestDownloadAvata == requestTag) {
        [self.delegate handleDownloadAvatarResult:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithBool:YES], @"result",
                                                   [requestInfo objectForKey:@"uid"], @"uid", 
                                                   error, @"error",
                                                   nil]];
    }
}

- (void) cancellAllRequest
{
    [self.queueLock lock];
    @try {
        [self.networkQueue cancelAllOperations];
    }
    @finally {
        [self.queueLock unlock];
    }
    
}

@end
