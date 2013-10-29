//
//  HahaViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-28.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HahaCore.h"
#import "RefreshTableFooterView.h"
#import "EGORefreshTableHeaderView.h"

@interface HahaViewController :  UIViewController<UITableViewDelegate, UITableViewDataSource,HahaDelegate,UITabBarDelegate,EGORefreshTableHeaderDelegate,RefreshTableFooterDelegate>

{
    
    NSMutableArray *hahaItems;
    NSMutableArray *Team;
    
    HahaRPC * hahaRpc;
    //远程过程调用协议
    int curPageNumber ; //页数
    
    BOOL isLoading;  //是否登录
    BOOL reloading;  //再次登录
    
    HahaItem *itemForDetail;//内容详细
    
    NSString *pageTitleStr;//页面标题
    
    BOOL isFristLoad;//首次登陆
    BOOL isappending;//是否加载
    
    UILabel *stateLabel;
    
    UIActivityIndicatorView *activity;//显示一个标准的旋转进度轮 重点在何时加载何时停止
    EGORefreshTableHeaderView *headView;//列表下拉刷新  自定义页数大小
    RefreshTableFooterView *footView;
    //再实现一个footerView加在列表下面，支持上拉列表松开加载下一页数据。
    
    
}
@property (nonatomic, retain) NSMutableArray *Team;
@property (nonatomic, retain) HahaRPC *hahaRpc;
@property (nonatomic, assign) BOOL isReadPag;
 //@property (retain, nonatomic) IBOutlet UITableView *tabView;//输出口
@property (retain, nonatomic) IBOutlet UITableView *tabView;//输出口
@property (nonatomic, retain) NSMutableArray * hahaItems;//哈哈列表
@property (nonatomic,assign) NSString * hahaType;//哈哈字符串
@property (nonatomic,retain) HahaItem *itemForDetail;
@property (nonatomic, retain) NSString *pageTitleStr;

@property (nonatomic, retain) UIActivityIndicatorView *activity;


@end
