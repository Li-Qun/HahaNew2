//
//  HahaViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-28.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "HahaViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "PublishOrCommentViewController.h"
#import "HahaItemDetailViewController.h"
#import "ReturnViewController.h"
#import "ReturnViewController.h"



#import "MainAppDelegate.h"
#import "MXImageUtils.h"
#import "MXAccountManager.h"

#import "CustomTabCell.h"

@class LoginViewController;
@class RegisterViewController;
@implementation HahaViewController
@synthesize hahaRpc;
@synthesize isReadPag;
@synthesize tabView;
@synthesize hahaItems;
@synthesize hahaType;
@synthesize itemForDetail;
@synthesize pageTitleStr;
@synthesize activity;
@synthesize Team;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"最哈" image:[UIImage imageNamed:@"title.png"] tag:0];
        self.title=@"最哈";//不是这里其作用显示的
        // self.view.backgroundColor = [UIColor yellowColor];
        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)notifyReadLoad
{
    isLoading = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"加载失败" message:@"点击重新加载" delegate:self cancelButtonTitle:@"重新加载" otherButtonTitles: nil];
    [alert show];
    [alert release];
    
}



-(void)notifyLoadStart
{
    
}



-(void)notifyLoadFinish
{
    
    // 对回来数据的处理，如果是上拉刷新，将数据加到页面的datasource， 如果是下来刷新，将页面datasource清空，重新加载数据
    if (reloading) //强制刷新
    {
        [self performSelector:@selector(doneLoadingTableViewData)];
    }
    if(isappending)
    {
        [self performSelector:@selector(footViewdoneLoadingTableViewData)];
    }
    if (isFristLoad)
    {
        if (hahaRpc.dataSourceForComment != nil)
        {
            for (int a = 0; a < [hahaRpc.dataSource count]; a++)
            {
                [hahaItems addObject:[hahaRpc.dataSource objectAtIndex:a]];
            }
        }
        
        [self.activity stopAnimating];//停止转动
        [stateLabel removeFromSuperview];//把当前view从它的父view和窗口中移除，同时也把它从响应事件操作的响应者链中移除
        [self.tabView setHidden:NO];
        curPageNumber++;
        [self.tabView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        //会创建一个新的线程实行reloadData函数，无参数，并且会等待函数退出后不再继续执行。
        isFristLoad = NO;
    }
}
-(void)notifyLoadFail
{
    isLoading = NO;
}


-(void)notifyLoadImgFinishwithPath:(NSString *)path andRow:(int)row

{
    
    HahaItem *tmp = [hahaItems objectAtIndex:row];
    NSString *name = [[path componentsSeparatedByString:@"/"] lastObject] ;
    
    
    if([name hasPrefix:@"icon"])//前缀 肖像
    {
        tmp.iconPath = path;
        [self.tabView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    else
    {
        tmp.imgPath = path;
        
        [self.tabView performSelector:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] afterDelay:0.2];
        
        [self performSelector:@selector(removeFootView) withObject:nil afterDelay:0.2];
    }
}
-(void)removeFootView
{
    [footView setFrame:CGRectMake(0.0f, self.tabView.contentSize.height, 320, 650)];
}


-(void)notifyLoadImgFail:(NSString *)path andRow:(int)row
{
    HahaItem *tmp = [hahaItems objectAtIndex:row];
    NSString *name = [[path componentsSeparatedByString:@"/"] lastObject] ;
    
    
    if([name hasPrefix:@"icon"])
    {
        tmp.iconPath = path;
        [self.tabView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
    
    //path 为本地默认图片！
    tmp.imgPath = path;
    
    [self.tabView performSelector:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:row inSection:0], nil] afterDelay:0.2];
    
    [self performSelector:@selector(removeFootView) withObject:nil afterDelay:0.25];
}

///////////////////
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //////////
    [self.tabView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    hahaRpc = [[HahaRPC alloc] init];
    [hahaRpc setDelegate:self];
    
    
    
    hahaItems = [[NSMutableArray alloc]init];
    Team=[[NSMutableArray alloc]init];
    self.Team = [[NSMutableArray alloc] initWithCapacity:0];
    
    curPageNumber =1; //first page number
    
    self.isReadPag = NO;
    
    
    self.hahaItems = [[NSMutableArray alloc] initWithCapacity:0];
    self.title = pageTitleStr;
    self.tabBarItem.title =[pageTitleStr substringFromIndex:4];
    
    self.hahaType = @"good";
    
    //[self.hahaRpc fetchHahaListInAsyn:self.hahaType pageNum:curPageNumber pageSize:_PAGE_SIZE];
    
    [self.hahaRpc fetchHahaList1:self.hahaType pageNum:curPageNumber pageSize:_PAGE_SIZE];
    
    
    //异步方式加载哈哈数据
    
    if (headView == nil) //下拉加载
    {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,-480.0f, self.view.frame.size.width, 480)];//设计刷新拉动视图
		view.delegate = self;
		[self.tabView addSubview:view];
		headView = view;
		[view release];
		
	}
	
	//  update the last update date
	[headView refreshLastUpdatedDate];
    
    //用于处理网络坏的状况
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activity setFrame:CGRectMake(119, 49, 22, 22)];
    [self.activity startAnimating];
    stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(147, 47, 60, 22)];
    [stateLabel setBackgroundColor:[UIColor clearColor]];
    [stateLabel setText:@"加载中..."];
    [stateLabel setTextColor:[UIColor grayColor]];
    [stateLabel setFont:[UIFont systemFontOfSize:13]];
    
    //[self.tabView setHidden:YES];
    
    [self.view addSubview:stateLabel];
    
    
    [self.view addSubview:self.activity];
    
    reloading = NO;
    isappending = NO;
    isFristLoad = YES;
   
    
    /*************UIBarButton*************/
    
    self.tabBarItem =[[UITabBarItem alloc]initWithTitle:@"最哈" image:[UIImage imageNamed:@"title.png"] tag:0];

    //创建一个左边按钮
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemAdd     target:self   action:@selector(clickLeftButton)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    
    
    [leftButton release];
    /*************UIBarButton*************/
    //    if(1)
    //    {
    //        NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n\n");
    //        self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    //        UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"设置"
    //                                                                         style:UIBarButtonItemStyleBordered
    //                                                                        target:self
    //                                                                        action:@selector (Pressed1:)];
    //
    //        self.navigationItem.rightBarButtonItem = rightButton1;
    //        self.navigationItem.hidesBackButton =YES;
    //        self.navigationItem.title = @"  ";
    //
    //        [rightButton1 release];//*/
    //    }
    //    else
    //    {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"登录"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector (clickRightButton)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.hidesBackButton =YES;
    self.navigationItem.title = @"最哈";
    [rightButton release];
    
    //*/
    
    
    
    
    
    
    
    /*************UIBarButton*************/
    
}

- (void)viewDidUnload//
{
    [self setTabView:nil];
    
    headView = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//回调函数
- (void)viewWillAppear:(BOOL)animated
{//视图即将可见时调用。默认情况下不执行任何操作
    [super viewWillAppear:animated];
    [self.tabView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{//视图已完全过渡到屏幕上时调用
    
    [self reloadTableViewDataSource];////=======
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{//视图被驳回时调用，覆盖或以其他方式隐藏。默认情况下不执行任何操作
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{//视图被驳回后调用，覆盖或以其他方式隐藏。默认情况下不执行任何操作
	[super  viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{//屏幕旋转 自动旋转界面方向
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //准确的说是用户拖动导致content offset(内容 增补)改变的时候就会调用
    [headView egoRefreshScrollViewDidScroll:scrollView];
    
    [footView RefreshScrollViewDidScroll:scrollView];
}

//需要scrollview在停止滑动后一定要执行某段代码的话应该搭配scrollViewDidEndDragging函数使用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //停止时执行的代码
    //   if(!decelerate)
    {
        [headView egoRefreshScrollViewDidEndDragging:scrollView];
        [footView RefreshScrollViewDidEndDragging:scrollView];
    }
    
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"XXXXXXXXXX%d",[self.hahaItems count]);
    return [self.hahaItems count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HahaItem * item =  [self.hahaItems objectAtIndex: [indexPath row]] ;
    
    CGFloat imgHeight;
    
    CGFloat contentHeight;
    
    CGFloat marginalHeight;
    
    CGFloat totalHeight;
    
    
    
    // 计算contentHeight
    
    UIFont *font = [UIFont systemFontOfSize:16];
    
	CGSize size = [item.content sizeWithFont:font constrainedToSize:CGSizeMake(300.f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    if ((size.height/20) >= 3)
    {
        contentHeight = 60.0f;
    }
    else
    {
        contentHeight = size.height;
    }
    
    
    
    // 计算
    if (item.imgUrl == nil && item.imgPath == nil)
    {
        //cell 没有图片
        marginalHeight =70.0f;
    }
    
    
    else if (item.imgUrl != nil && ![item.imgPath isEqualToString:@""])
    {
        //cell 图片已经展示
        marginalHeight = 60.0f;
    }
    
    else
    {
        //cell 图片还没展示 ActivityIndicator 在cell中展示
        marginalHeight = 98.0f;
    }
    
    
    
    // 计算imgHeight
    
    if (item.imgUrl!= nil && ![item.imgPath isEqualToString:@""])
    {
        UIImage *img = [UIImage imageWithContentsOfFile:item.imgPath];
        imgHeight = img.size.height;
    }
    
    
    
    totalHeight = imgHeight + contentHeight + marginalHeight+3;
    
    return totalHeight;
}
// Customize the appearance of table view cells.
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"CellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
//    }
//
//    HahaItem * item =  [self.hahaItems objectAtIndex: [indexPath row]];
//    cell.textLabel.text = [NSString stringWithFormat:@"%@",item.name];
//
//    return cell;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{//实现TableView数据源方法
    
    
    static NSString *CellIdentifier = @"Cell";
    
    HahaItem * item =  [self.hahaItems objectAtIndex: [indexPath row]] ;
    
    CustomTabCell *cell = (CustomTabCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    if (cell == nil) //
    {
        UINib* nib = [UINib nibWithNibName:@"Cell" bundle:nil];
        NSArray* array = [nib instantiateWithOwner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    
    // cell的背景颜色
    
    int tmp = indexPath.row;
    NSString *CellBGPath = [[NSString alloc] init];
    if (tmp%2 == 1)
    {
        CellBGPath = [[NSBundle mainBundle] pathForResource:@"Home_List_Item1.9" ofType:@"png"];
    }
    else
    {
        CellBGPath = [[NSBundle mainBundle] pathForResource:@"Home_List_Item2.9" ofType:@"png"];
    }
    
    UIImageView *CellImgView = [[UIImageView alloc] init];
    [CellImgView setImage:[MXImageUtils imageFromFile:CellBGPath]];
    [CellImgView setFrame:cell.frame];
    [cell setBackgroundView:CellImgView];
    [CellImgView release];
    [CellBGPath release];
    
    
    //对cell中的各个元素赋值
    
    cell.hahaItemPubTimeLabel.text = [NSString stringWithFormat:@"%@",item.pubDate];
    cell.praiseCountLabel.text = [NSString stringWithFormat:@"%@",item.praiseCount];
    cell.contemptCountLabel.text = [NSString stringWithFormat:@"%@",item.contemptCount];
    cell.commentCountLabel.text = [NSString stringWithFormat:@"%@",item.commentCount];
    cell.hahaItemContentLab.text = [NSString stringWithFormat:@"%@",item.content];
    cell.publisherNameLabel.text = [NSString stringWithFormat:@"%@",item.name];
    
    CGFloat imgHeight;
    CGFloat contentHeight;
    
    // Hahaitem 内容
    
 	UIFont *font = [UIFont systemFontOfSize:16];
    
	CGSize size = [item.content sizeWithFont:font constrainedToSize:CGSizeMake(300.f, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    
    
    //用于计算haha文字高度
    
    if ((size.height/20) >3  || (size.height/20) ==3)
    {
        [cell.hahaItemContentLab setFrame:CGRectMake(13, 8, 294, 60)];
        cell.hahaItemContentLab.numberOfLines = 3;
        contentHeight = 60.0f;
    }
    else
    {
        [cell.hahaItemContentLab setFrame:CGRectMake(13, 8, 294, size.height)];
        
        cell.hahaItemContentLab.numberOfLines = (size.height/20);
        
        contentHeight = size.height;
        
    }
    
    //哈哈图片内容加载
    // 1.url == nil 表示没有图片
    // 2.url != nil 但是 path ==nil 表示有图片，但是还没去服务器下载（如果发送请求后，会将path 赋值为@“”）
    // 3.url != nil 并且  path !=@“” 表示已经有图片 需要加载
    
    //start
    
    if ( item.imgPath == nil && item.imgUrl !=nil)
    {
        // webservice
        
        NSString *tepStr =[[NSString alloc] initWithFormat:@"%d",indexPath.row];
        
        [hahaRpc getHahaItemPicture1:item.imgUrl withName:[[item.imgUrl componentsSeparatedByString:@"/"] lastObject] andIndexRow:tepStr];
        cell.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.indicator setFrame:CGRectMake(138, contentHeight +8, 22, 22)];
        cell.indicator.hidesWhenStopped = YES;
        [cell.indicator startAnimating];
        [cell addSubview:cell.indicator];
        
        
        item.imgPath = @"";
        [tepStr release];
        
    }
    if (item.imgUrl !=nil && ![item.imgPath isEqual: @""] )
    {
        
        UIImage *img =[UIImage imageWithContentsOfFile:item.imgPath];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, contentHeight + 16, img.size.width, img.size.height)];
        [imgView setImage:img];
        [cell addSubview:imgView];
        
        imgHeight = img.size.height;
        [cell.indicator stopAnimating];
    }
    
    
    
    
    if (item.iconUrl != nil && item.iconPath == nil)
    {
        NSString *tepStr = [[NSString alloc] initWithFormat:@"%d",indexPath.row];
        NSString *iconName = [NSString stringWithFormat:@"icon%@",[[item.iconUrl componentsSeparatedByString:@"/"] lastObject]];
        [hahaRpc getAccountIcon:item.iconUrl withName:iconName andIndexRow:tepStr];
        item.iconPath =@"";
        [tepStr release];
        
    }
    if(item.iconUrl != nil && item.iconPath != @"")
    {
        
        UIImage *img =[UIImage imageWithContentsOfFile:item.iconPath];
        [cell.publisherIcon setImage:img];
    }
    
    
    if ([item.isMarked isEqualToString:@"true"])
    {
        [cell.praiseBtn setImage:[UIImage imageNamed:@"Home_List_Item_Icon_Good_Gray.png"] forState:UIControlStateNormal];
        [cell.praiseBtn setUserInteractionEnabled:NO];
        
        
        [cell.contemptBtn setImage:[UIImage imageNamed:@"Home_List_Item_Icon_Bad_Gray.png"] forState:UIControlStateNormal];
        [cell.contemptBtn setUserInteractionEnabled:NO];
        
    }
    
    
    [cell.praiseBtn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    [cell.praiseBtn setTag:[item.msgid intValue]];
    cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    [cell.contemptBtn addTarget:self action:@selector(btnPress:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contemptBtn setTag:(0 - [item.msgid intValue])];
    cell.contemptBtn.titleLabel.text = [NSString stringWithFormat:@"%d",indexPath.row];
    
    
    if (item.imgPath == @"")
    {
        [cell.separateLine setHidden:YES];
    }
    else
    {
        [cell.separateLine setHidden:NO];
        [cell.separateLine setFrame:CGRectMake(13, imgHeight+contentHeight + 24, 294, 1)];
    }
    
    
    [cell.publisherIcon setFrame:CGRectMake(13, imgHeight + contentHeight + 33, 25, 25)];
    [cell.publisherNameLabel setFrame:CGRectMake(43, imgHeight + contentHeight + 28, 153, 21)];
    [cell.hahaItemPubTimeLabel setFrame:CGRectMake(43, imgHeight + contentHeight + 42, 153, 21)];
    [cell.praiseBtn setFrame:CGRectMake(196,imgHeight + contentHeight + 35, 18, 18)];
    [cell.praiseCountLabel setFrame:CGRectMake(216, imgHeight + contentHeight + 36, 24, 18)];
    [cell.contemptBtn setFrame:CGRectMake(237, imgHeight + contentHeight + 35, 18, 18)];
    [cell.contemptCountLabel setFrame:CGRectMake(258, imgHeight + contentHeight + 36, 24, 18)];
    [cell.commentImgView setFrame:CGRectMake(278, imgHeight + contentHeight + 35, 18, 18)];
    //TODO:warning
    [cell.commentCountLabel setFrame:CGRectMake(298, imgHeight + contentHeight + 36, 24, 18)];
    
    
    //end
    
    
    if (footView == nil )
    {
        RefreshTableFooterView *view = [[RefreshTableFooterView alloc] init];
        view.delegate = self;
        footView = view;
        [self.tabView addSubview:footView];
        [view release];
    }
    [footView setFrame:CGRectMake(0.0f, self.tabView.contentSize.height, 320, 650)];
    //  update the last update date
    
    //FIXME: unclear methods
    //[footView refreshLastUpdatedDate];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//表示发生了表视图某行被选中的事件，后面的参数具体指明了是哪个表视图（tableView）的哪一行（indexPath里包含）被选中。
    
    itemForDetail = [self.hahaItems objectAtIndex: indexPath.row];
    
    MainAppDelegate *app  = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.hahaItemVC1.hahahItem=itemForDetail;
    
    
    HahaItemDetailViewController *hahaItemDetailView = [[HahaItemDetailViewController alloc] initWithNibName:@"HahaItemDetailViewController" bundle:nil];
    hahaItemDetailView.hahahItem = itemForDetail;
    // NSLog(@"@@@@@@@@%@",hahaItemDetailView.hahahItem.name);
    hahaItemDetailView.hidesBottomBarWhenPushed = YES;//跳入页面隐藏tabbar
    
    [self.navigationController pushViewController:hahaItemDetailView animated:YES];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
}
//*/
- (void)dealloc
{
    
    [tabView release];
    [hahaItems release];
    [stateLabel release];
    [self.hahaRpc release];
    itemForDetail = nil;
    headView = nil;
    //   [_tabView release];
   // [_tabView release];
    [super dealloc];
    
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource
{
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    
    //如果上拉刷新的web service正在执行， 不能执行下拉刷新的操作
    if (isappending)
    {
        [headView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tabView];
    }
    else
    {
        self.isReadPag = YES;
        curPageNumber = 1;
        hahaRpc.appendTofirst = YES;
        reloading = YES;
        [hahaRpc fetchHahaListInAsyn:self.hahaType pageNum:curPageNumber pageSize:_PAGE_SIZE];
    }
	
}

- (void)doneLoadingTableViewData
{
	[headView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tabView];
    
    if (reloading)
    {
        [self.hahaItems removeAllObjects];
        
        if (hahaRpc.dataSourceForComment != nil)
        {
            for (int a = 0; a < [hahaRpc.dataSource count]; a++)
            {
                [hahaItems addObject:[hahaRpc.dataSource objectAtIndex:a]];
                
            }
        }
    }
    [self.tabView performSelector:@selector(reloadData) withObject:nil afterDelay:0.3f];
	reloading = NO;
	
}



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//释放更新
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    
	return reloading; // should return if data source model is reloading
	
}
//最后一次改变的数据
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    isLoading = YES;
    [hahaRpc fetchHahaListInAsyn: self.hahaType  pageNum:1 pageSize:_PAGE_SIZE];
    
}


// 用于footView
- (void)footviewReloadTableViewDataSource
{
    //如果下拉刷新的web service正在执行， 不能执行上拉刷新的操作
	if (reloading)
    {
        [footView RefreshScrollViewDataSourceDidFinishedLoading:self.tabView];
    }
    
    else
    {
        [hahaRpc fetchHahaListInAsyn:self.hahaType pageNum:curPageNumber + 1 pageSize:_PAGE_SIZE];
        
        isappending = YES;
    }
    
	
}
- (void)footViewdoneLoadingTableViewData
{
	
	//  model should call this when its done loading
    
    [footView RefreshScrollViewDataSourceDidFinishedLoading:self.tabView];
    curPageNumber++;
    if (hahaRpc.dataSource != nil)
    {
        for (int a = 0; a < [hahaRpc.dataSource count]; a++)
        {
            [hahaItems addObject:[hahaRpc.dataSource objectAtIndex:a]];
            
        }
    }
    [self.tabView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    isappending = NO;
    
}


#pragma mark -
#pragma mark RefreshTableFooterDelegate Methods

- (void)RefreshTableFooterDidTriggerRefresh:(RefreshTableFooterView *)view
{
	[self footviewReloadTableViewDataSource];
}

- (BOOL)RefreshTableFooterDataSourceIsLoading:(RefreshTableFooterView *)view
{
	
	return isappending; // should return if data source model is reloading
	
}

- (NSDate*)RefreshTableFooterDataSourceLastUpdated:(RefreshTableFooterView *)view
{
	return [NSDate date]; // should return date data source was last changed
}

-(void)clickLeftButton//发布一条哈哈
{
    // LoginViewController *Login=[[LoginViewController alloc]init];
    MainAppDelegate *app =(MainAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if(app.isLonIn==NO)
    {
        RegisterViewController  *VC1=[[RegisterViewController alloc]init];
        [self.navigationController pushViewController:VC1 animated:YES];
        [VC1 release];
        
    }
    else
    {
        PublishOrCommentViewController *VC1=[[PublishOrCommentViewController alloc]init];
        VC1.writeOrCommentHaha = YES;
        [self.navigationController pushViewController:VC1 animated:YES];
        VC1.writeOrCommentHaha = YES;
        [VC1 release];
    }
    
    //
    //  [self presentViewController:self.navigationController animated:NO completion:nil];
}
-(void)btnPress:(id)sender

{
    UIButton *temp = (UIButton *)sender;
    NSString *msgid = [NSString stringWithFormat:@"%d",temp.tag];
    //实现一个标签Tag列表的效果
    CustomTabCell *cell = (CustomTabCell *)[self.tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[temp.titleLabel.text intValue] inSection:0]];
    HahaItem *tmp = [self.hahaItems objectAtIndex:[temp.titleLabel.text integerValue]];
    tmp.isMarked = @"true";
    if ([msgid intValue] < 0)//判断是踩的一项
    {
        [hahaRpc doQuickRemark:msgid withType:@"bad"];
        CustomTabCell *cell = (CustomTabCell *)[self.tabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[temp.titleLabel.text intValue] inSection:0]];
        NSString *countStr =  [NSString stringWithFormat:@"%d",[cell.contemptCountLabel.text intValue] +1];
        cell.contemptCountLabel.text = countStr;
        HahaItem *hahaTmp = [self.hahaItems objectAtIndex:[temp.titleLabel.text intValue]];
        [hahaTmp setValue:countStr forKey:@"contemptCount"];
        
        
    }
    
    else
    {
        [hahaRpc doQuickRemark:msgid withType:@"good"];
        NSString *countStr =  [NSString stringWithFormat:@"%d",[cell.praiseCountLabel.text intValue] +1];
        cell.praiseCountLabel.text = countStr;
        
        HahaItem *hahaTmp = [self.hahaItems objectAtIndex:[temp.titleLabel.text intValue]];
        [hahaTmp setValue:countStr forKey:@"praiseCount"];
    }
    
    [cell.praiseBtn setUserInteractionEnabled:NO];
    [cell.contemptBtn setUserInteractionEnabled:NO];
    [cell.contemptBtn setImage:[UIImage imageNamed:@"Home_List_Item_Icon_Bad_Gray.png"] forState:UIControlStateNormal];
    [cell.praiseBtn setImage:[UIImage imageNamed:@"Home_List_Item_Icon_Good_Gray.png"] forState:UIControlStateNormal];
}
-(void)publishAHaha//发布一条哈哈
{
    MainAppDelegate *app =(MainAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (app.isLonIn)
    {
        
        PublishOrCommentViewController *publishView = [[PublishOrCommentViewController alloc] initWithNibName:@"PublishOrCommentViewController" bundle:nil];
        publishView.writeOrCommentHaha = YES;
        publishView.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:publishView animated:YES];
    }
    else
    {
        LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

-(void)clickRightButton
{
    ReturnViewController  *VC1=[[ReturnViewController alloc]init];
    [self.navigationController pushViewController:VC1 animated:YES];
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;
    //  [VC1 release];
}
@end
