//
//  HahaCore.m
//  HahaDemo
//
//  Created by 程凯 cheng on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "HahaCore.h"
#import "MainAppDelegate.h"
#import "Reachability.h"

#define _COMMENT_PAGE_SIZE 5

@implementation HahaItem 

@synthesize commentCount =_commentCount;
@synthesize msgid=_msgid;
@synthesize content=_content;
@synthesize pubDate= _pubDate;
@synthesize name= _name;
@synthesize uid = _uid;
@synthesize praiseCount = _praiseCount;
@synthesize contemptCount = _contemptCount;
@synthesize imgUrl = _imgUrl;
@synthesize bigImgUrl = _bigImgUrl;
@synthesize imgPath =_imgPath;
@synthesize bigImgPath =_bigImgPath;
@synthesize isMarked =_isMarked;
@synthesize iconUrl =_iconUrl;
@synthesize iconPath =_iconPath;

-(NSString *)briefContent {
//    if(_content)
    return  [[self content] substringToIndex:(10)];
} 

-(void)dealloc 
{
    [_msgid release];
    [_content release];
    [_pubDate release];
    [_name release];
    [_uid release];
    [_imgUrl release];
    [_bigImgUrl release];
    [super dealloc];
}

@end


@implementation HahaCommentItem

@synthesize commentatorIconPicUrl = _commentatorIconPicUrl;
@synthesize commenttatorNameStr =_commenttatorNameStr;
@synthesize commentTimeStr =_commentTimeStr;
@synthesize commentContentStr = _commentContentStr;
@synthesize commentatorID =_commentatorID;
@synthesize commentID =_commentID;
@synthesize commentatorIconPicPath =_commentatorIconPicPath;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.commentatorIconPicUrl = nil;
        self.commentatorIconPicPath = nil;
    }
    //something to init;
    return self;
}


@end


@implementation  HahaRPC


//=============== Http degegate implements ================//
@synthesize appendTofirst =_appendTofirst;
@synthesize dataSource = _dataSource;
@synthesize dataSourceForComment =_dataSourceForComment;

@synthesize hostReach =_hostReach;


//处理一些乱码问题

-(NSString *)contentHandle :(NSString *)content
{
    content = [content stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"&ldquo;" withString:@"“"];
    content = [content stringByReplacingOccurrencesOfString:@"&rdquo;" withString:@"”"];
    content = [content stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"……"];
    content = [content stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    content = [content stringByReplacingOccurrencesOfString:@"&rsquo;" withString:@"’"];
    content = [content stringByReplacingOccurrencesOfString:@"&gt" withString:@">"];
    content = [content stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"—"];
    content = [content stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    content = [content stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
    content = [content stringByReplacingOccurrencesOfString:@"â¦" withString:@"..."];
    content = [content stringByReplacingOccurrencesOfString:@"&lsquo;" withString:@"‘"];
    content = [content stringByReplacingOccurrencesOfString:@"&darr;" withString:@"↓"];
    content = [content stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];  
    content = [content stringByReplacingOccurrencesOfString:@"&shy;" withString:@"。"];
    content = [content stringByReplacingOccurrencesOfString:@"&para;" withString:@"¶"];
    content = [content stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    content = [content stringByReplacingOccurrencesOfString:@"&rarr;" withString:@"→"];
    content = [content stringByReplacingOccurrencesOfString:@"&cap;" withString:@"∩"];
    content = [content stringByReplacingOccurrencesOfString:@"&hearts;" withString:@"♥"];
    content = [content stringByReplacingOccurrencesOfString:@"&asymp;" withString:@"≈"];
    
    return content;
}
-(id) init
{
    if (self = [super init]) 
    {

        self.dataSourceForComment = [[NSMutableArray alloc] initWithCapacity:0];
        
        _hostReach = [[Reachability reachabilityWithHostName:@"www.haha.mx"] retain];
        self.dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return  self;
}


- (void)requestStarted:(ASIHTTPRequest *)request
{
    
    NSLog(@"========== start load data ==============");
    [_hahaDelegate notifyLoadStart];
}

- (void)requestFinished:(ASIHTTPRequest *)request {

     NSLog(@"========== load finished  ==============");

    // xiao bai
    
    NSString * jsionString  =  [request responseString];
    if ([[request.userInfo valueForKey:@"target"] isEqual:@"getHahaComment"]) 
    {
//        //NSLog(@"diaoyong");
        [self appendToDataSourceWithHahaComment:jsionString];
        [_hahaDelegate notifyLoadCommentDataFinished];
    }
    else if([[request.userInfo valueForKey:@"target"] isEqual:@"pic"])
    {

        NSString *path = [NSString stringWithFormat:@"%@/tmp/%@",NSHomeDirectory(),[request.userInfo valueForKey:@"imgNamge"]];

        
        BOOL success = [[request responseData] writeToFile:path atomically:YES];
        
        
        NSAssert(success, @"write to file wrong", nil);
 
        
        [_hahaDelegate notifyLoadImgFinishwithPath:path andRow:[[request.userInfo valueForKey:@"row"] intValue]];
        
        //[_hahaDelegate notifyLoadImgFail:@"" andRow:0];
    }
    else if([[request.userInfo valueForKey:@"target"] isEqual:@"remark"] || [[request.userInfo valueForKey:@"target"] isEqual:@"publish"])
    {
       
        //NSString *responseId =  [request responseData]
        NSString *responseId = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        [_hahaDelegate notifyCommendHahaEndWithResponseID:responseId];
    }
        
    else
    {    
        [self appendToDataSource:jsionString];
        [_hahaDelegate notifyLoadFinish];    
    }
    

//    [HahaUtils dumpHahaList:_dataSource];
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"==========  load data failed ==============");
    
    NSString *urlType = [request.userInfo valueForKey:@"target"];
    NSLog(@"%@",urlType);
    
    // Todo: 根据urlType 来调用相应的处理函数
    if ([urlType isEqualToString:@"getHahaList"])
    {
        [_hahaDelegate notifyReadLoad];
    }
    
    
    else if ([urlType isEqualToString:@"getHahaComment"]) 
    {

        
        [_hahaDelegate notifyReadLoad];
    }
    
    else if ([urlType isEqualToString:@"pic"]) 
    {

        NSString *path = [[NSBundle mainBundle] pathForResource:@"Home_List_Image_Notdisplay" ofType:@"png"];
        
        [_hahaDelegate notifyLoadImgFail:path andRow:[[request.userInfo valueForKey:@"row"] intValue]];

    }
    
    else
    {    
        [_hahaDelegate notifyLoadFail];
    }
}





-(void)setDelegate:(id)delegate {
    _hahaDelegate = delegate;
}


-(void) setCommentDataSource:(NSMutableArray *)dataSource
{
    _dataSourceForComment = dataSource;
}

-(void) setDataSource:(NSMutableArray *)dataSource
{
    _dataSource = dataSource;
}





-(void)  appendToDataSourceWithHahaComment :(NSString * ) jsionString 
{
    [_dataSourceForComment removeAllObjects];
    NSDictionary *jsonObj =[jsionString JSONValue]; 

    if ([[jsonObj valueForKey:@"count"] isEqual:@"0"]) 
    {
        _dataSourceForComment = nil;
        return ;
    }
    else
    {
        NSArray *items = (NSArray *)[jsonObj valueForKey:@"comments"];
       //NSLog(@">>>total [%d] items", [items count] );
       //遍历所有items
        int ndx;
        for (ndx = 0; ndx < items.count; ndx++) 
        {
            
            NSDictionary *item = (NSDictionary *)[items objectAtIndex:ndx];
            HahaCommentItem *commentItem = [[HahaCommentItem alloc] init];
            commentItem.commentatorID = [item valueForKey:@"user_id"];
            commentItem.commentTimeStr = [item valueForKey:@"time"];
            commentItem.commenttatorNameStr =[item valueForKey:@"user_name"];
            NSString *tmpContent = [item valueForKey:@"content"];
            commentItem.commentContentStr =[self contentHandle:tmpContent];
            commentItem.commentID = [item valueForKey:@"id"];
            
            NSString *tempImgUrl = [item valueForKey:@"user_pic"];
        //    NSAssert([tempImgUrl isKindOfClass:[NSString class]], @"!!!!!!!!!!!!!!");
            commentItem.commentatorIconPicUrl = [tempImgUrl stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"\\"]]];
            
            
            if(YES )//&& ![self hasExistItemWithCommentList:commentItem.commentID]) 
            {
                //[_dataSourceForComment removeAllObjects];
                if(_appendToCommentFirst) 
                {
                    [_dataSourceForComment insertObject:commentItem atIndex:0]; //追加到数据源的开头
                    _appendToCommentFirst = NO;
                } 
                else 
                {
                    [_dataSourceForComment addObject:commentItem]; //追加到数据源的结尾
                }
                
            } 
            
            
            [item release];
        }
    }
    //[jsonObj release];
    

}

-(void)appendToDataSource:(NSString *)jsionString  
{
    [_dataSource removeAllObjects];

    NSDictionary *jsonObj =[jsionString JSONValue];    
    NSArray *items = (NSArray *)[jsonObj valueForKey:@"HahaItems"];
    
    //遍历所有items
    int ndx;
    for (ndx = 0; ndx < items.count; ndx++) {
        
        NSDictionary *item = (NSDictionary *)[items objectAtIndex:ndx];
        HahaItem * hahaItem = [[HahaItem alloc] init];

        
        NSString *tmpContent = [[NSString alloc] initWithFormat:@"%@",[item valueForKey:@"content"]];
        hahaItem.content = [self contentHandle:tmpContent];



        if(!hahaItem.content || [hahaItem content].length == 0) 
        {
            hahaItem.content = @"";
        }
        
        hahaItem.uid = [item valueForKey:@"uid"];
        hahaItem.msgid = [item valueForKey:@"id"];
        hahaItem.name = [item valueForKey:@"name"];
        hahaItem.name = [hahaItem.name stringByReplacingOccurrencesOfString:@"&middot;" withString:@"·"];
        
        hahaItem.pubDate= [item valueForKey:@"pubDate"];
        hahaItem.contemptCount = [item valueForKey:@"contemptCount"];
        hahaItem.praiseCount = [item valueForKey:@"praiseCount"];
        hahaItem.isMarked = [item valueForKey:@"isMarked"];
        hahaItem.commentCount = [item valueForKey:@"commentCount"];
 
        NSString *tempImgUrl = [item valueForKey:@"pic"];
        
        
        if (![tempImgUrl isEqualToString:@""]) 
        {
            hahaItem.imgUrl = [tempImgUrl stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"\\"]]];
        }
        else
        {
            hahaItem.imgUrl = nil;
        }
        
        hahaItem.imgPath = nil;
        
        
        tempImgUrl = [item valueForKey:@"originPic"];
        
        if (![tempImgUrl isEqualToString:@""]) 
        {
            hahaItem.bigImgUrl = [tempImgUrl stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"\\"]]];
            
        }
        else
        {
            hahaItem.bigImgUrl = nil;
        }

        hahaItem.bigImgPath = nil;
        
        NSString *iconUrlStr = [item valueForKey:@"icon"];
        
        if (![iconUrlStr isEqualToString:@""]) 
        {
            hahaItem.iconUrl = [iconUrlStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"\\"]]];
        }
        
        else
        {
            hahaItem.iconUrl = nil;
        }
        
        hahaItem.iconPath = nil;
   
        
        if(_dataSource != nil && ![self hasExistItem:hahaItem.msgid]) 
        {
            if(_appendTofirst) 
            {
                [_dataSource insertObject:hahaItem atIndex:0]; //追加到数据源的开头
                _appendTofirst = NO;
            }
            else 
            {
                [_dataSource addObject:hahaItem]; //追加到数据源的结尾
            }
                       
        } 
        else 
        {
            [item release];
        }
        
    }
    //[jsonObj release];
   
}

-(BOOL)hasExistItem:(NSString *)msgid
{
    for(int i= 0; i < _dataSource.count; i++) {
        HahaItem * item = (HahaItem *) [_dataSource objectAtIndex:i];
       if(item.msgid == msgid) 
       {
           return YES;
       }
    }
    return  NO;
}


-(BOOL)hasExistItemWithCommentList:(NSString *)msgid
{
    for(int i= 0; i < _dataSource.count; i++) {
         HahaCommentItem* item = (HahaCommentItem *) [_dataSource objectAtIndex:i];
        if(item.commentID == msgid) 
        {
            return YES;
        }
    }
    return  NO;
}

- (void)fetchHahaListInAsyn:(NSString *)type pageNum:(int)pn pageSize:(int)ps
{

      NSString  * url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php?r=get_joke&type=%@&pn=%d&pagesize=%d",type,pn,ps];
    
    
     ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];

    
    
    [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
    [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"User-Agent" value:@"AppleWebKit/533.18.1 (KHTML, like Gecko) Version/5.0.2 Safari/533.18.5"];
    
    [request setDelegate:self];
    

    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"getHahaList",@"target", nil]];
    
    [request startAsynchronous];
    

}

//同步获取Hahalist

 -(id)fetchHahaList: (NSString * ) type pageNum:(int) pn pageSize:(int) ps
{

     
    NSString  * url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php?r=get_joke&type=%@&pn=%d&pagesize=%d",type,pn,ps];     
     
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];


     [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
     [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
     [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
     [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
     [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
     [request startSynchronous];
     
	BOOL success = ([request responseStatusCode] == 200);
    if(success) 
    {
        
        NSString * jsionString  =  [request responseString];
        [self appendToDataSource:jsionString];
        [_hahaDelegate notifyLoadFinish];
         return jsionString;
    }
   else return @"fail";
    
}

//获取haha评论
-(id)fetchhahaComment:(NSString *)msgid pageNum:(int)pn pageSize:(int)ps
{
    
    NSString  * url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php?r=get_comment&jid=%@&page=%d&offset=%d",msgid,pn,ps];
    
    NSLog(@"url= %@",url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    request.userInfo = [[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"target",nil] autorelease];

    [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
    [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
    
    [request setDelegate:self];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"getHahaComment",@"target", nil]];

    [request startAsynchronous];
    BOOL success = ([request responseStatusCode] == 200);
    NSLog(@"$$$$$$$$$$$$$$$$$%d",[request responseStatusCode]);//500代表内部服务器错误

    if(success)
    {
        
        NSString * jsionString  =  [request responseString];
        [self appendToDataSource:jsionString];
        [_hahaDelegate notifyLoadFinish];
        return jsionString;
    }
    else return @"fail";
     
}

//发布哈哈（同步）
-( int)publishHahaItem:(NSString *)itemContent
{
    
    NSString *url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    
    
    
    NSMutableArray *cookiesArr =[NSMutableArray arrayWithArray:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    [request setRequestCookies:cookiesArr];
    [request addPostValue:@"insert_joke" forKey:@"r"];
    [request addPostValue:itemContent forKey:@"joke_content"];
    [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
    [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
    [request setDelegate:self];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"publish",@"target", nil]];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    BOOL Ok=([request responseStatusCode ]==200);
    
    int response;
    if(Ok)
    {
        NSString *responseString=[request responseString];
        response=[responseString intValue];
    }
    else
        response=6;
    return response;
//    NSString *jsonString=[request responseString];
 //   int jsonObj=[jsonString intValue];
//    if(Ok)//单元测试时 打开
//    {
//        
//        return jsonObj;
//    }
//    else
//    {
//        jsonObj=6;
//        return jsonObj;
//        
//    }
}


- (id)doRemark:(NSString *)msgId withContent:(NSString *)cont byUser:(NSString *)userID
{    

    NSString *url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php"];
    
        NSLog(@"%@",url);
    NSLog(@"||||||||||||||http://www.haha.mx/mobile_app_api.php?r=insert_comment&jid=%@&content=%@&juid=%@",msgId,cont,userID);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    

    [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
    [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
    

    NSMutableArray *cookiesArr =[NSMutableArray arrayWithArray:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    [request setRequestCookies:cookiesArr];
    [request addPostValue:@"insert_comment" forKey:@"r"];
    [request addPostValue:msgId forKey:@"jid"];
    [request addPostValue:cont forKey:@"content"];
    [request addPostValue:userID forKey:@"juid"];
    [request setRequestMethod:@"POST"];
        [request setDelegate:self];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"remark",@"target", nil]];
    
   
    [request startSynchronous];
    
    int response;
    BOOL Ok = ([request responseStatusCode] == 200);
     NSLog(@"++++++++++++%d",[request responseStatusCode]);//500代表内部服务器错误

    if(Ok)
    {
        NSString *responseString=[request responseString];
        response=(int)[responseString intValue];
        NSLog(@"##########%d",response);//7  代表什么？？？？？？？？
    }
    else
        response=6;
    return (id)response;
}



#pragma mark




- (void)doQuickRemark:(NSString *)msgid withType:(NSString *)type 
{

    NSString *url = [NSString stringWithFormat:@"http://www.haha.mx/mobile_app_api.php?r=vote&jid=%@&v=%@",msgid,type];
    
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];

    [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
    [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
    
    [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"quickRemar",@"target", nil]];
    

    [request startSynchronous];
    
    
    //需要进一步的处理，目前先处理到这块
}
- (id)getHahaItemPicture:(NSString *)imgUrl withName:(NSString *)imgName andIndexRow:(NSString *)indexRow
{

        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imgUrl]];
        

        [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
        [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
        [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
        [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
        
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:imgName, @"imgNamge",@"pic",@"target",indexRow,@"row", nil]]; 
        [request setDelegate:self];
        
        [request startAsynchronous];
        BOOL Ok=([request responseStatusCode]==200);
        if(Ok){  
        NSData *jsonString=[request responseData];
            return jsonString;
        }
        else return @"fail";
}


- (void)getAccountIcon:(NSString *)iconUrl withName:(NSString *)iconName andIndexRow:(NSString *)indexRow
{
    if (![self.hostReach isReachable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"哈哈" message:@"网络状况差，请检查网络" delegate:nil cancelButtonTitle:@"I Know" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else
    {
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:iconUrl]];
      
        [request addRequestHeader:@"device" value:[[UIDevice currentDevice] uniqueIdentifier]];
        [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.7"];
        [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate"];
        [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
        [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008101315 Ubuntu/8.10 (intrepid) Firefox/3.0.3"];
        
        [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:iconName, @"imgNamge",@"pic",@"target",indexRow,@"row", nil]];
        
        
        [request setDelegate:self];
        
        [request startAsynchronous];
    }
}

@end




@implementation UIView(MXAdditions)

- (void) Shake 
{
    
	CAKeyframeAnimation *keyAn = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	[keyAn setDuration:0.5f];
	NSArray *array = [[NSArray alloc] initWithObjects:
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
					  [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
					  nil];
	[keyAn setValues:array];
	[array release];
	NSArray *times = [[NSArray alloc] initWithObjects:
					  [NSNumber numberWithFloat:0.1f],
					  [NSNumber numberWithFloat:0.2f],
					  [NSNumber numberWithFloat:0.3f],
					  [NSNumber numberWithFloat:0.4f],
					  [NSNumber numberWithFloat:0.5f],
					  [NSNumber numberWithFloat:0.6f],
					  [NSNumber numberWithFloat:0.7f],
					  [NSNumber numberWithFloat:0.8f],
					  [NSNumber numberWithFloat:0.9f],
					  [NSNumber numberWithFloat:1.0f],
					  nil];
	[keyAn setKeyTimes:times];
	[times release];
	[self.layer addAnimation:keyAn forKey:@"TextAnim"];
}



@end



@implementation NSNull(MXAdditions)

-(NSInteger *)count
{
    return 0;
}



@end



