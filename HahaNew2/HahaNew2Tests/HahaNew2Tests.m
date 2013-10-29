//
//  HahaNew2Tests.m
//  HahaNew2Tests
//
//  Created by Li-Qun on 13-9-13.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//
#import "MXSingleton.h"
#import "Utils.h"
#import "SBJson.h"
#import "NSData-AES.h"
#import "MXAccountManager.h"
#import "HahaNew2Tests.h"
#import"HahaCore.h"

@implementation HahaNew2Tests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}
//  testSingupAccount (HahaNew2Tests) failed: +[NSSingleton allocWithZone] - invalid call -

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
  //  STFail(@"Unit tests are not implemented yet in HahaNew2Tests");
}
/*
-(void)testfetchHahaListInSync//同步获取Hahalist
{
    HahaRPC *rpc=[[HahaRPC alloc]init];
   NSData  *data=[rpc fetchHahaList:@"hot"pageNum:1 pageSize:10];
  
    NSDictionary *jsondictionary= [data JSONValue];
    NSArray *items=(NSArray *)[jsondictionary valueForKey:@"HahaItems"];
    NSLog(@">>>>total [%d] items",items.count );
    for(int i=0;i<items.count;i++)
    {
        NSDictionary *Item=(NSDictionary *)[items objectAtIndex:i];
        NSLog(@"%@======\n %d\n",[Item valueForKey:@"content"],i);
    }

    [rpc release];
}
 
//测试加载一张图片
-(void)testgetHahaItemPicture
{
    HahaRPC   *rpc= [[HahaRPC alloc]init];
    NSData *data =[rpc getHahaItemPicture:@"http://img2.3lian.com/img2007/13/85/20080405142608974.png"
                            withName:nil andIndexRow:nil];
    NSLog(@"jsonString--->%@", data);
    [rpc release];
}
//发一条哈哈文本
-(void)testPublishHahaItem
{
   
      HahaRPC   *rpc= [[HahaRPC alloc]init];
      int num=[rpc publishHahaItem:@"This is a Haha API"];
 
     if(num==0)NSLog(@"0 代表 服务器端出错");
     else if(num==1)NSLog(@"1 代表 发布成功");
     else if(num==2)NSLog(@"2 代表 用户可能被屏蔽.");
     else if(num==3)NSLog(@"3 代表 发布的内容可能含有敏感过滤词！");
     else if(num==4)NSLog(@"4 代表 用户未登录");
     else if(num==5)NSLog(@"5 代表 用户发表评论的间隔时间太短，您可以提示用户：如 您讲的太快了，休息一下吧〜");
     else if(num==6)NSLog( @"------fail" );
     [rpc release];
}//error: testPublishHahaItem (HahaNew2Tests) failed: +[NSSingleton allocWithZone] - invalid call -


//测试haha评论获取

-(void)testfetchhahaComment
{
    
    HahaRPC *rpc=[[HahaRPC alloc]init];
    id  *data=[rpc fetchhahaComment:@"new"pageNum:1 pageSize:10];
    // NSLog(@"======%@=====\n",data);
    NSDictionary *jsondictionary= [data JSONValue];
    NSArray *items=(NSArray *)[jsondictionary valueForKey:@"HahaItems"];
    NSLog(@">>>>>>>>>>>>>>>>>>>total [%d] items",items.count );
    for(int i=0;i<items.count;i++)
    {
        NSDictionary *Item=(NSDictionary *)[items objectAtIndex:i];
        NSLog(@"%@======\n %d\n",[Item valueForKey:@"content"],i);
    }
    [rpc release];
}//
 */
 -(void)testNewdoRemark
 {//(id)doRemark:(NSString *)msgId withContent:(NSString *)cont byUser:(NSString *)userID
 
      HahaRPC   *rpc= [[HahaRPC alloc]init];
     int response=[rpc doRemark:@"979923" withContent:@"发布哈哈评论"
                          byUser:@"30031538"];
 
     if(response==0)NSLog(@"0 代表 服务器端出错");
 
     else if(response==1)NSLog(@"1 代表 发布成功~");
 
     else if(response==2)NSLog(@"2 代表 用户未登录或已被屏蔽");
 
     else if(response==3)NSLog(@"3 代表 呀〜含有敏感过滤词");
 
     else if(response==5)NSLog(@"5 代表 用户发表评论的间隔时间太短 您可以提示用户：如 您讲的太快了，休息一下吧〜");
 
     else if(response==6)NSLog( @"------fail" );
 
     else NSLog(@"客户端请求没有成功响应 ");
     [rpc release];
 }//*/

@end
