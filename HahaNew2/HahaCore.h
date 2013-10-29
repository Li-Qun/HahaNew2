//
//  HahaCore.h
//  HahaDemo
//
//  Created by 程凯 cheng on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "Reachability.h"

#include "JSON.h"

#define REMARK_TYPE_PRAISE = 0;
#define REMARK_TYPE_CONTEMPT =1;

#define ERRCODE_DUPLICATE_REMARK = 1;        


//描述一个哈哈条目
@interface HahaItem : NSObject {
    NSString * _msgid;
    NSString * _content;
    NSString * _pubDate;
    
    //userName 和userid
    NSString * _name;
    NSString * _uid;
    NSString *_isMarked;
    
    //ImgUrl为空，表示没有图片链接
    NSString * _imgUrl;
    NSString * _imgPath;       //图片本地路径
    NSString * _bigImgUrl;
    NSString * _bigImgPath;
    NSString * _iconUrl;
    NSString * _iconPath;
    
    NSString * _praiseCount ;           //赞赏条数
    NSString * _contemptCount;      //鄙视条数
    NSString * _commentCount;

}


@property (nonatomic,copy) NSString *commentCount;
@property (nonatomic,copy) NSString * imgPath;

@property (nonatomic,copy)  NSString * msgid;
@property (nonatomic,copy)  NSString * content;
@property (nonatomic,copy)  NSString * pubDate;
@property (nonatomic,copy)  NSString * name;
@property (nonatomic,copy)  NSString * uid;
@property (nonatomic,copy)  NSString * praiseCount;
@property (nonatomic,copy)  NSString * contemptCount;
@property (nonatomic,copy)  NSString * imgUrl;
@property (nonatomic,copy)  NSString * bigImgUrl;
@property (nonatomic,copy)  NSString * bigImgPath;
@property (nonatomic,copy)  NSString * iconUrl;
@property (nonatomic,copy)  NSString * iconPath;

@property (nonatomic,copy)  NSString *isMarked;



//获取摘要（前n个字符）
- (NSString * ) briefContent;     

@end


//哈哈的一条评论

@interface HahaCommentItem : NSObject 
{
    NSString *_commentID;
    NSString *_commentatorID;
    NSString *_commentatorIconPicUrl;
    NSString *_commentatorIconPicPath;
    NSString *_commenttatorNameStr;
    NSString *_commentTimeStr;
    NSString *_commentContentStr;
}

@property (nonatomic, retain) NSString *commentID;
@property (nonatomic, retain) NSString *commentatorID;
@property (nonatomic, retain) NSString *commentatorIconPicUrl;
@property (nonatomic, retain) NSString *commenttatorNameStr;
@property (nonatomic, retain) NSString *commentTimeStr;
@property (nonatomic, retain) NSString *commentContentStr;
@property (nonatomic, retain) NSString *commentatorIconPicPath;



@end




//哈哈网路层的委托接口
@protocol HahaDelegate

@optional

-(void) notifyLoadStart;

-(void) notifyReadLoad;

-(void) notifyLoadFail;

-(void) notifyLoadFinish;

-(void) notifyLoadCommentDataFinished;

-(void) notifyLoadImgFinishwithPath:(NSString *)path andRow:(int) row;
 
-(void) notifyCommendHahaEndWithResponseID:(NSString *)ID;

-(void) notifyLoadImgFail:(NSString *)path andRow:(int) row;
 

@end



//实现和服务器的通讯，如获取haha列表，发布一个评论等
@interface HahaRPC : NSObject <ASIHTTPRequestDelegate>
{
    id<HahaDelegate> _hahaDelegate;
    NSMutableArray * _dataSource; 
    NSMutableArray * _dataSourceForComment;
    BOOL _appendTofirst; //指示数据追加至数据源的末尾或开头
    BOOL _appendToCommentFirst; //指示追加数据源到开头或结尾 （用于commentlist）

    
    Reachability  *_hostReach;
}
@property (nonatomic, assign) BOOL appendTofirst;
@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) NSMutableArray *dataSourceForComment;


@property (nonatomic, retain) Reachability *hostReach;


//通过jsion的方式追加到数据源(commentList)
-(void)  appendToDataSourceWithHahaComment :(NSString * ) jsionString ;


//通过jsion的方式追加到数据源
-(void)  appendToDataSource :(NSString * ) jsionString ;

//设置haha委托对象
-(void) setDelegate: (id) delegate ;

//设置数据源绑定用于接受数据
-(void) setDataSource:(NSMutableArray *) dataSource ;

//设置comment的数据源

-(void) setCommentDataSource:(NSMutableArray *)dataSource;



//以异步方式获取哈哈列表
- (void) fetchHahaListInAsyn  :(NSString *) type  pageNum:(int) pn pageSize:(int) ps;

//以同步方式获取哈哈列表
-(id)fetchHahaList: (NSString * ) type pageNum:(int) pn pageSize:(int) ps;

//判断haha消息id是否已经存在,避免重复
-(BOOL) hasExistItem:(NSString *) msgid;

//判断haha评论id是否已经纯在，避免重复
-(BOOL)hasExistItemWithCommentList:(NSString *)msgid;

//获取哈哈列表
- (id)  fetchHahaList : (NSString * ) type pageNum:(int) pn pageSize:(int) ps;

//获取一条哈哈的评论
- (id)  fetchhahaComment:(NSString *)msgid pageNum:(int) pn pageSize:(int) ps;

//发布一条哈哈
//- (void) publishHahaItem : (NSString *) itemContent;
-(NSInteger)publishHahaItem:(NSString *)itemContent;
//评论某条哈哈
- (id)  doRemark :(NSString * ) msgId withContent:(NSString * ) cont byUser: (NSString *)userID;

//快速评论某条哈哈，赞同或者反对
- (void)  doQuickRemark :(NSString * ) msgid withType:(NSString *) type;

//得到一条哈哈的图片

- (id) getHahaItemPicture:(NSString *) imgUrl withName: (NSString *)imgName andIndexRow:(NSString *) indexRow;

//获取account的icon

- (void) getAccountIcon:(NSString *) iconUrl withName: (NSString *)imgName andIndexRow:(NSString *) indexRow;

@end


@interface UIView(PTAdditions)


- (void) Shake;


@end
