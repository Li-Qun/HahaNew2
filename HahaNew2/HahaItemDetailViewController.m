//
//  HahaItemDetailViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-30.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "MainViewController.h"
#import "HahaItemDetailViewController.h"
#import "CommentItem.h"
#import "RefreshTableFooterView.h"
#import "PublishOrCommentViewController.h"
#import "MainAppDelegate.h"
#import "LoginViewController.h"
#define _DRAG_MARGIN 15
#define _COMMENT_PAGE_SIZE 5
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
//@interface HahaItemDetailViewController ()
//
//@end

@implementation HahaItemDetailViewController
 
@synthesize commentTableView;
@synthesize hahaRPC;
@synthesize hahahItem;
@synthesize dataSource;
@synthesize comment ;
@synthesize commentItem ;
@synthesize isLoading ;


// haha delegate

- (void)notifyReadLoad
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载评论失败" message:@"请检查网络后，重新加载评论" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [alert release];
}


-(void)notifyLoadStart
{
    //_isLoading = YES;
   
}

-(void)notifyLoadFinish
{
    
}
-(void)notifyLoadImgFinishwithPath:(NSString *)path andRow:(int)row

{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    hahahItem=app.hahaItemVC1.hahahItem;
    
    NSString *name = [[path componentsSeparatedByString:@"/"] lastObject] ;
    isFirstLoading = NO;
    
    
    if ([name hasPrefix:@"big"])
    {
        isLoadingImg = NO;
        hahaItem.bigImgPath = path;
        app.hahaItemVC1.hahahItem.bigImgPath=path;
       // NSLog(@"$$$$$$$$%@",hahaItem.name);
        [self.commentTableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] waitUntilDone:NO];
        
        
    }
    else
    {
        
        HahaCommentItem *tmp = [dataSource objectAtIndex:row];
    
        tmp.commentatorIconPicPath = path;
        
        [self.commentTableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self performSelector:@selector(removeFootView)];
    }
}



-(void)notifyLoadCommentDataFinished
{
    curPage++;
    isLoading = NO;
    if (appending)
    {
        [self performSelector:@selector(doneLoadingTableViewData)];
    }
    else
    {
        if (hahaRPC.dataSourceForComment != nil)
        {
            for (int a = 0; a < [hahaRPC.dataSourceForComment count]; a++)
            {
                [dataSource addObject:[hahaRPC.dataSourceForComment objectAtIndex:a]];
                
            }
            
            [self.commentTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
    }
}



-(void)notifyLoadImgFail:(NSString *)path andRow:(int)row
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    hahahItem=app.hahaItemVC1.hahahItem;
    path = [[NSBundle mainBundle] pathForResource:@"Haha_Detail_List_Image_Notdisplay" ofType:@"png"];
    hahaItem.bigImgPath = path;
    app.hahaItemVC1.hahahItem.bigImgPath=path;
    [self.commentTableView reloadRowsAtIndexPaths:[[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:0], nil] autorelease]  withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void)removeFootView
{
    [footerView removeFromSuperview];
    if (self.commentTableView.contentSize.height > 367.0f)
    {
        if (self.hahahItem.bigImgUrl == nil || (self.hahahItem != nil && ![self.hahahItem.bigImgPath isEqualToString:@""]))
        {
            [footerView setFrame:CGRectMake(0.0f, self.commentTableView.contentSize.height, 320, 650)];
            [self.commentTableView addSubview:footerView];
        }
        
    }
}


-(void)dealloc
{
    [comment release];
    [hahaItem release];
    [hahaRPC release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        dataSource = [[NSMutableArray alloc] init];
        
        self.hahaRPC = [[HahaRPC alloc] init];
        [self.hahaRPC setDelegate:self];
        //[_hahaRPC setDataSourceForComment:_dataSource];
        
 /*************************初始化右边按钮*********************/
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"评论"
                                                                        style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                     action:@selector (jumpToCommentView)];
        
        self.navigationItem.rightBarButtonItem = rightButton;
        self.navigationItem.hidesBackButton =YES;        
        self.commentItem =rightButton;
        self.navigationItem.rightBarButtonItem = rightButton;        
       [rightButton release];//*/
        isFirstLoading = YES;

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //修改返回按钮
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemReply     target:self   action:@selector(backBtnPress)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    [leftButton release];
 

    curPage = 1;
    
    self.title = @"查看详细";
    
    if (footerView == nil)
    {
        RefreshTableFooterView *view = [[RefreshTableFooterView alloc] initWithFrame:CGRectZero];
        view.delegate = self;
        footerView = view;
        //[self.commentTableView addSubview:_footerView];
        //[view release];
    }
    
    // Do any additional setup after loading the view from its nib.
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    curPage = 1;
    if (self.dataSource != nil)
    {
        [self.dataSource removeAllObjects];
    }
    [hahaRPC fetchhahaComment:self.hahahItem.msgid pageNum:curPage pageSize:_COMMENT_PAGE_SIZE];
    
    isLoading = YES;
    
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    // 如果下载图片失败～～页面消失后，将bigImgPath设置为nil，下次页面出现的时候可以重新加载图片
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    hahahItem=app.hahaItemVC1.hahahItem;
   // NSLog(@"####%@",hahaItem.bigImgPath);
    if ([app.hahaItemVC1.hahahItem .bigImgPath isEqualToString: [[NSBundle mainBundle] pathForResource:@"Haha_Detail_List_Image_Notdisplay" ofType:@"png"]])
    {
        hahaItem.bigImgPath = nil;
        app.hahaItemVC1.hahahItem .bigImgPath=nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    commentTableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

 


-(UIImage *)imgHandlerFuction:(UIImage *)img
{
    if (img.size.width > 294)
        
    {
        CGFloat scale = 294/img.size.width;
        
        UIGraphicsBeginImageContext(CGSizeMake(img.size.width *scale, img.size.height * scale));
        [img drawInRect:CGRectMake(0, 0, img.size.width * scale, img.size.height * scale)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        return scaledImage;
    }
    else
    {
        return img;
    }
    
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [footerView RefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [footerView RefreshScrollViewDidEndDragging:scrollView];
}





-(void)jumpToCommentView
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (app.isLonIn)
    {
        
        PublishOrCommentViewController *commentView = [[[PublishOrCommentViewController alloc] initWithNibName:@"PublishOrCommentViewController" bundle:nil]autorelease];
        
        commentView.writeOrCommentHaha = NO;
        commentView.itemID = self.hahahItem.msgid;
        [commentView setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:commentView animated:YES];
    }
    else
    {
        LoginViewController *lonInView = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]autorelease];
        [self.navigationController pushViewController:lonInView animated:YES];
    }
}

//TalbeView delegae and dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([dataSource count] + 1);
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    hahahItem=app.hahaItemVC1.hahahItem;
   // NSLog(@"|||||||||||%@",hahahItem.bigImgUrl);
    static NSString *hahaIdentifier =@"haha";
    static NSString *commentIdentifier = @"comment";
    
    UITableViewCell *hahaCell = [tableView dequeueReusableCellWithIdentifier:hahaIdentifier];
    CommentItem *commentCell = (CommentItem *)[tableView dequeueReusableCellWithIdentifier:commentIdentifier];
 
   
    
    if (indexPath.row == 0)
    {
       
        CGFloat contentHeight;  // 保存内容高度
        CGFloat imgHeight;      // 保存图片高度
        
        UIFont *font = [UIFont systemFontOfSize:16];
        CGSize csize = [app.hahaItemVC1.hahahItem .content sizeWithFont:font constrainedToSize:CGSizeMake(294, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        contentHeight = csize.height;
        
        
        
        if (hahaCell == nil)
        {
            hahaCell =[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:hahaIdentifier] autorelease];
     
            
            
            // 用户icon
            UIImageView *iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.iconPath]];
            [iconImgView setFrame:CGRectMake(13, 6, 29, 29)];
            [hahaCell addSubview:iconImgView];
            [iconImgView release];
            
            
            //用户昵称
            
            UILabel *userNameLab =[[UILabel alloc] initWithFrame:CGRectMake(45, 6, 200, 29)];
            userNameLab.text =app.hahaItemVC1.hahahItem.name;
            [userNameLab setFont:[UIFont boldSystemFontOfSize:16]];
            [userNameLab setBackgroundColor:[UIColor clearColor]];
            [userNameLab setTextColor:RGBCOLOR(100, 104, 109)];
         //   NSLog(@"####%@\n\n",app.hahaItemVC1.hahahItem.name);
            [hahaCell addSubview:userNameLab];
            [userNameLab release];
            
           
            
            //发表时间
            UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(187, 6, 120, 29)];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
            NSString *strYesterdayDate = [dateFormatter stringFromDate:[NSDate dateWithTimeInterval:(-24*60*60) sinceDate:[NSDate date]]];
            
            if ([[app.hahaItemVC1.hahahItem.pubDate substringToIndex:10] isEqualToString:[strYesterdayDate substringToIndex:10]])
            {
                NSString *timeStr = [NSString stringWithFormat:@"昨天%@",[app.hahaItemVC1.hahahItem.pubDate substringFromIndex:11]];
                timeLab.text = timeStr;
            }
            else if([[hahaItem.pubDate substringToIndex:10] isEqualToString:[strDate substringToIndex:10]])
            {
                NSString *timeStr = [NSString stringWithFormat:@"今天%@",[app.hahaItemVC1.hahahItem.pubDate substringFromIndex:11]];
                timeLab.text = timeStr;
            }
            else
            {
                timeLab.text =app.hahaItemVC1.hahahItem.pubDate;
            }
            
            [timeLab setTextAlignment:UITextAlignmentRight];
            [timeLab setFont:[UIFont systemFontOfSize:12]];
            [timeLab setBackgroundColor:[UIColor clearColor]];
            [timeLab setTextColor:RGBCOLOR(133, 138, 143)];
            [hahaCell addSubview:timeLab];
            [dateFormatter release];
            [timeLab release];
            
            //haha文字内容
            
            
            UILabel *hahaContentLab =[[UILabel alloc] initWithFrame:CGRectMake(13, 49, 294, csize.height)];
            
            hahaContentLab.numberOfLines = (csize.height / 20) ;
            [hahaContentLab setFont:font];
            hahaContentLab.text = app.hahaItemVC1.hahahItem.content;
            [hahaContentLab setBackgroundColor:[UIColor clearColor]];
            [hahaContentLab setTextColor:RGBCOLOR(100, 104, 109)];
            [hahaCell addSubview:hahaContentLab];
            [hahaContentLab release];
            
            //快评////////赞
            UIButton *btnPraise = [[UIButton alloc] init];
            [btnPraise  setImage:[UIImage imageNamed:@"Haha_Detail_List_Icon_Good"] forState:UIControlStateNormal];
            [btnPraise .titleLabel setFont:[UIFont systemFontOfSize:15]];
            [btnPraise  setTitle:app.hahaItemVC1.hahahItem.praiseCount forState:UIControlStateNormal];
            [btnPraise   setTitleColor:RGBCOLOR(106, 157, 29) forState:UIControlStateNormal];
            
            [btnPraise  setTag:[app.hahaItemVC1.hahahItem.msgid intValue]];
            [btnPraise  addTarget:self action:@selector(btnPress1:) forControlEvents:UIControlEventTouchUpInside];
            
            
            UIButton *btnContempt = [[UIButton alloc] init];
            [btnContempt setImage:[UIImage imageNamed:@"Haha_Detail_List_Icon_Bad"] forState:UIControlStateNormal];
            [btnContempt.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [btnContempt setTitle:app.hahaItemVC1.hahahItem.contemptCount forState:UIControlStateNormal];
            [btnContempt setTitleColor:RGBCOLOR(161, 84, 36) forState:UIControlStateNormal];
            
            [btnContempt setTag:(0-[app.hahaItemVC1.hahahItem.msgid intValue])];
            [btnContempt addTarget:self action:@selector(btnPress1:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            
            if ([app.hahaItemVC1.hahahItem.isMarked isEqualToString:@"true"])
            {
                
                btnPraise.enabled = NO;
                [btnPraise setImage:[UIImage imageNamed:@"Haha_Detail_List_Icon_Good_Gray"] forState:UIControlStateNormal];
                
                [btnContempt setImage:[UIImage imageNamed:@"Haha_Detail_List_Icon_Bad_Gray"] forState:UIControlStateNormal];
                
                btnContempt.enabled = NO;
            }
            else
            {
                btnPraise.enabled = YES;
                btnContempt.enabled = YES;
            }
            
            [hahaCell addSubview:btnPraise];
            [btnPraise release];
            [hahaCell addSubview:btnContempt];
            [btnContempt release];
            
            //收藏图片button
            UIButton *btnSave = [[UIButton alloc] init];
            [btnSave setTitle:@"收藏" forState:UIControlStateNormal];
            [btnSave setTitleColor:RGBCOLOR(141, 109, 24) forState:UIControlStateNormal];
            [btnSave addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
            [btnSave.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [btnSave setTag:15];
 
            if (app.hahaItemVC1.hahahItem.bigImgUrl == nil)
            {
                [btnSave setUserInteractionEnabled:NO];
                
            }
            
            [hahaCell addSubview:btnSave];
            [btnSave release];
            
            

            
            
            //评语
            
            NSString *commentCountBGViewPath = [[NSBundle mainBundle] pathForResource:@"Haha_Detail_Comment.9" ofType:@"png"];
            UIImageView *commentCountBGView = [[UIImageView alloc] initWithImage:[MXImageUtils imageFromFile:commentCountBGViewPath]];
            //[commentCountBGView setFrame:CGRectZero];
            [commentCountBGView setTag:16];
            
            
            
            UILabel *commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(13,0,300, 35)];//
            [commentCountLabel setBackgroundColor:[UIColor clearColor]];
            [commentCountLabel setFont:[UIFont systemFontOfSize:14]];
            NSString *commentCountLabelStr = [NSString stringWithFormat:@"%@条评论",app.hahaItemVC1.hahahItem.commentCount];
            [commentCountLabel setText:commentCountLabelStr];
            [commentCountLabel setTextColor:RGBCOLOR(100, 104, 109)];
            [commentCountBGView addSubview:commentCountLabel];
            
            
            [hahaCell addSubview:commentCountBGView];
            [commentCountBGView release];
            
          
            
            /////////////////////////
            
            [[hahaCell viewWithTag:16] setFrame:CGRectMake(0,  contentHeight + 73 +51, 320, 35)];
            [[hahaCell viewWithTag:15] setFrame:CGRectMake(213,  contentHeight + 82, 63, 34)];
            [[hahaCell viewWithTag:(0-[app.hahaItemVC1.hahahItem.msgid intValue])] setFrame:CGRectMake(129,  contentHeight + 82, 63, 34)];
            [[hahaCell viewWithTag:[app.hahaItemVC1.hahahItem.msgid intValue]] setFrame:CGRectMake(45,  contentHeight + 82, 63, 34)];
            UIImage *img = [UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.bigImgPath];
            UIImage *imgForShow =  [self imgHandlerFuction:img];
            
            imgHeight = imgForShow.size.height;
            UIImageView *contentImg = [[UIImageView alloc] initWithImage: imgForShow];
            [contentImg setFrame:CGRectMake(13,contentHeight +57, 294, imgForShow.size.height)];
            [hahaCell addSubview:contentImg];
            
            [hahaCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
        }
        
        UIImage *img = [UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.bigImgPath];
        UIImageView *img1=[[UIImageView alloc]init];
          img1.image=img;
    
        //哈哈图片内容加载
        // 1.url == nil 表示没有图片
        // 2. url != nil 但是 path ==nil 表示有图片，但是还没去服务器下载（如果发送请求后，会将path 赋值为@“”）
        // 3.url != nil 并且  path !=@“” 表示已经有图片 需要加载
        
        if (app.hahaItemVC1.hahahItem.bigImgUrl != nil && app.hahaItemVC1.hahahItem.bigImgPath == nil)
        {//bigImgUrl
            hahahItem=app.hahaItemVC1.hahahItem;
       //      NSLog(@"|||||||||||%@",hahahItem.bigImgUrl);
            NSString *tepBigStr =[[NSString alloc] initWithFormat:@"%d",indexPath.row];
            NSString *imgBname = [NSString stringWithFormat:@"big%@",[[app.hahaItemVC1.hahahItem.imgUrl componentsSeparatedByString:@"/"] lastObject]];
            [hahaRPC getHahaItemPicture:app.hahaItemVC1.hahahItem.bigImgUrl withName:imgBname andIndexRow:tepBigStr];
            //[hahaCell addSubview: indicator];
            [indicator setFrame:CGRectMake(149, 55 + contentHeight, 22, 22)];
            [img1 setFrame:CGRectMake(149, 55 + contentHeight, 22, 22)];
                     isLoadingImg = YES;
            [indicator startAnimating];
            
            self.hahahItem.bigImgPath = @"";
            [tepBigStr release];
            
        }
        
        if (![app.hahaItemVC1.hahahItem.bigImgPath isEqual: @""])
        {
            
            if ([app.hahaItemVC1.hahahItem.bigImgPath isEqualToString: [[NSBundle mainBundle] pathForResource:@"Haha_Detail_List_Image_Notdisplay" ofType:@"png"]])
            {
                imgHeight = 120;
                UIImageView *contentImg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"Haha_Detail_List_Image_Notdisplay"]];
                
                [contentImg setFrame:CGRectMake(13,contentHeight +57, 150, 120)];
                
               [img1 setFrame:CGRectMake(13,contentHeight +57, 150, 120)];
                
                //[hahaCell addSubview:contentImg];
            }
            else
            {
                
                UIImage *img = [UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.bigImgPath];
                UIImage *imgForShow =  [self imgHandlerFuction:img];
                
                imgHeight = imgForShow.size.height;
                
                if ([app.hahaItemVC1.hahahItem.bigImgPath hasSuffix:@"gif"])
                {
                    
                    UIWebView *webView = [[UIWebView alloc] init];
                    [webView setUserInteractionEnabled: NO];
                    [webView setFrame:CGRectMake(13, contentHeight +57, imgForShow.size.width, imgForShow.  size.height)];
                    NSURL *url = [NSURL fileURLWithPath:app.hahaItemVC1.hahahItem.bigImgPath];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    [webView loadRequest:request];
                    [hahaCell addSubview:webView];
                    
                }
                
                else
                {
                    UIImageView *contentImg = [[UIImageView alloc] initWithImage: imgForShow];
                    [contentImg setFrame:CGRectMake(13,contentHeight +57, 294, imgForShow.size.height)];
                    
                     [img1 setFrame:CGRectMake(13,contentHeight +57, 294, imgForShow.size.height)];
                    
                   // [hahaCell addSubview:contentImg];
                    [contentImg release];
                }
            }
            
            [indicator stopAnimating];
        }
        
        if (![app.hahaItemVC1.hahahItem.bigImgPath isEqual: @""])
        {
            [[hahaCell viewWithTag:16] setFrame:CGRectMake(0, imgHeight + contentHeight + 73 +34, 320, 35)];
            [[hahaCell viewWithTag:15] setFrame:CGRectMake(213, imgHeight + contentHeight + 65, 63, 34)];
            [[hahaCell viewWithTag:(0-[app.hahaItemVC1.hahahItem.msgid intValue])] setFrame:CGRectMake(129, imgHeight + contentHeight + 65, 63, 34)];
            [[hahaCell viewWithTag:[app.hahaItemVC1.hahahItem.msgid intValue]] setFrame:CGRectMake(45, imgHeight + contentHeight + 65, 63, 34)];
        }
        else
        {
            [[hahaCell viewWithTag:16] setFrame:CGRectMake(0,  contentHeight + 73 +51, 320, 35)];
            [[hahaCell viewWithTag:15] setFrame:CGRectMake(213,  contentHeight + 82, 63, 34)];
            [[hahaCell viewWithTag:(0-[app.hahaItemVC1.hahahItem.msgid intValue])] setFrame:CGRectMake(129,  contentHeight + 82, 63, 34)];
            [[hahaCell viewWithTag:[app.hahaItemVC1.hahahItem.msgid intValue]] setFrame:CGRectMake(45,  contentHeight + 82, 63, 34)];
        }
        if (![app.hahaItemVC1.hahahItem.bigImgPath hasSuffix:@"gif"])
        {
            UIScrollView *scrollview=[[UIScrollView alloc]initWithFrame:img1.frame];
            ImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.bigImgPath]];
            [scrollview addSubview:ImgView];
            scrollview.contentSize = ImgView.frame.size;
            scrollview.maximumZoomScale= 2.5;//允许放大2倍
            scrollview.minimumZoomScale=0.5;
            scrollview.delegate = self;
            ImgView.backgroundColor=[UIColor clearColor];
            scrollview.backgroundColor=[UIColor whiteColor];
            [hahaCell addSubview:  scrollview];
            [scrollview release];
        }

        [img1  release];
        return hahaCell;
    }
    
    
    //评论haha 的cell
    else
    {
        HahaCommentItem *item = [dataSource objectAtIndex:(indexPath.row - 1)];
        
        if (commentCell == nil)
        {
            commentCell = (CommentItem *)[[[NSBundle mainBundle] loadNibNamed:@"CommentItem"  owner:self options:nil] lastObject];
        }
        
        
        
        
     //   NSString *bgPath = [[NSBundle mainBundle] pathForResource:@"Haha_Detail_Comment_BG.9" ofType:@"png"];
        UIImageView *cellImgView = [[UIImageView alloc] init];
     //   [cellImgView setImage:[MXImageUtils imageFromFile:bgPath]];
        [commentCell setBackgroundView:cellImgView];
        [cellImgView release];
        
        
        UIFont *font = [UIFont systemFontOfSize:14];
        
        CGSize size = [item.commentContentStr sizeWithFont:font constrainedToSize:CGSizeMake(265.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        [commentCell.commentContentLab setFrame:CGRectMake(42, 24, 265, size.height)];
        commentCell.commentContentLab.numberOfLines = (size.height/17);
        commentCell.commentContentLab.text = item.commentContentStr;
        
        
        NSString *nameLabelStr = [NSString stringWithFormat:@"%@ 说",item.commenttatorNameStr];
        commentCell.commenttatorNameLab.text = nameLabelStr;
        [commentCell.commenttatorNameLab setFont:[UIFont systemFontOfSize:14]];
        commentCell.commentTimeLab.text = [item.commentTimeStr substringToIndex:10];
        
        if (item.commentatorIconPicUrl == nil)
        {
            [commentCell.commentatorIcon setImage:[UIImage imageNamed:@"IconDefault"]];
        }
        else if (item.commentatorIconPicUrl != nil && item.commentatorIconPicPath == nil)
        {
            
            NSString *index = [NSString stringWithFormat:@"%d",(indexPath.row - 1)];
            NSString *iconName = [NSString stringWithFormat:@"%@",[[item.commentatorIconPicUrl componentsSeparatedByString:@"/"] lastObject]];
            
            
            [hahaRPC getHahaItemPicture:item.commentatorIconPicUrl withName:iconName andIndexRow:index];
            item.commentatorIconPicPath = @"";
            
        }
        else
        {
            UIImage *icon =  [UIImage imageWithContentsOfFile:item.commentatorIconPicPath];
            [commentCell.commentatorIcon setImage:icon];
        }
        
        [commentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (self.commentTableView.contentSize.height > 367.0f)
        {
            if (self.hahahItem.bigImgUrl == nil || (self.hahahItem != nil && ![self.hahahItem.bigImgPath isEqualToString:@""]))
            {
                [footerView setFrame:CGRectMake(0.0f, self.commentTableView.contentSize.height, 320, 650)];
            }
            
        }
        [self performSelector:@selector(removeFootView)];
        return commentCell;
    }

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row == 0)
    {
        
        float imgHeight;
        
        float contentHeight ;
        
        float totalHeight;
        
        
        UIFont *font = [UIFont systemFontOfSize:16];
        CGSize size = [ app.hahaItemVC1.hahahItem.content sizeWithFont:font constrainedToSize:CGSizeMake(294.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        contentHeight = size.height;
        
        if (isLoadingImg )
        {
            //处理indicator在转圈圈的时候的
            totalHeight = contentHeight +142 +18;
        }
        else
        {
            UIImage *img = [UIImage imageWithContentsOfFile:app.hahaItemVC1.hahahItem.bigImgPath];
            
            UIImage *imgForShow =  [self imgHandlerFuction:img];
            
            imgHeight = imgForShow.size.height;
            
            totalHeight = imgHeight + contentHeight +142 ;
        }
        
        return  totalHeight;
        
    }
    else
    {
        HahaCommentItem *item = [dataSource objectAtIndex:(indexPath.row - 1)];
        
        UIFont *font = [UIFont systemFontOfSize:14];
        
        CGSize size = [item.commentContentStr sizeWithFont:font constrainedToSize:CGSizeMake(265.0f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        
        return (size.height + 34.0f);
        
    }
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [hahaRPC fetchhahaComment:self.hahahItem.msgid pageNum:curPage pageSize:_COMMENT_PAGE_SIZE];
}


- (void)reloadTableViewDataSource{
    //  should be calling your tableviews data source model to reload
    //  put here just for demo
    
    
    [hahaRPC fetchhahaComment:self.hahahItem.msgid pageNum:curPage + 1 pageSize:_COMMENT_PAGE_SIZE];
    appending = YES;
    
}

- (void)doneLoadingTableViewData{
    //  model should call this when its done loading
    appending = NO;//上拉刷新 页面页面刷新完毕调用此方法
    [footerView RefreshScrollViewDataSourceDidFinishedLoading:self.commentTableView];
    //   页面页面刷新完毕调用此方法
    if (hahaRPC.dataSourceForComment != nil)
    {
        for (int a = 0; a < [hahaRPC.dataSourceForComment count]; a++)
        {
            [dataSource addObject:[hahaRPC.dataSourceForComment objectAtIndex:a]];
            
        }
        
        [self.commentTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)RefreshTableFooterDidTriggerRefresh:(RefreshTableFooterView *)view
{
    
    [self reloadTableViewDataSource];
    
}

- (BOOL)RefreshTableFooterDataSourceIsLoading:(RefreshTableFooterView *)view
{
    return appending; // should return if data source model is reloading
}

- (NSDate*)RefreshTableFooterDataSourceLastUpdated:(RefreshTableFooterView *)view
{
    return [NSDate date]; // should return date data source was last changed
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return ImgView;
}
//按钮的superview 起了大作用

-(void)btnPress1:(id)sender

{
    
    UIButton *currentButton = (UIButton *)sender;
    currentButton.enabled = NO;
    //msgid ======>NSString
    NSString *msgid = [NSString stringWithFormat:@"%d",currentButton.tag];
    UIButton *otherButton = (UIButton *)[currentButton.superview viewWithTag:(0 -[msgid intValue])];
    otherButton.enabled = NO;
    [self.hahahItem setValue:@"true" forKey:@"isMarked"];
    if ([msgid intValue] < 0)//Bad
    {
        
        NSString *badCountStr = [NSString stringWithFormat:@"%d",([currentButton.titleLabel.text intValue] +1)];
        [currentButton setTitle:badCountStr forState:UIControlStateNormal];
        //把快速评论按钮enable  没设按钮背景
        [self.hahahItem setValue:badCountStr forKey:@"contemptCount"];
        
        [hahaRPC doQuickRemark:msgid withType:@"bad"];
    }
    else
    {
        
        
        NSString *goodCountStr = [NSString stringWithFormat:@"%d",([currentButton.titleLabel.text intValue] +1)];
        [currentButton setTitle:goodCountStr forState:UIControlStateNormal];
        [self.hahahItem setValue:goodCountStr forKey:@"praiseCount"];
        
        
        [hahaRPC doQuickRemark:msgid withType:@"good"];
        
    }
    
}
//保存share

-(void)share
{
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:hahaItem.bigImgPath], nil, nil, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"哈哈" message:@"收藏成功" delegate:nil cancelButtonTitle:@"知道" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

@end
