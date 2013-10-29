//
//  HahaItemDetailViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-30.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//



#import "HahaCore.h"
#import "CommentItem.h"
#import "RefreshTableFooterView.h"
#import <UIKit/UIKit.h>


#import "MainViewController.h"
 
@interface HahaItemDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, HahaDelegate,RefreshTableFooterDelegate,UIScrollViewDelegate>
{
    UITableView *commentTableView;
    HahaCommentItem *comment;
    NSMutableArray *dataSourse;
    HahaItem *hahaItem;//个人 时间 icon的信息
    HahaRPC *hahaRpc;
    RefreshTableFooterView *footerView;
    BOOL isLoading;
    BOOL isFirstLoading;
    BOOL appending;
    BOOL isLoadingImg;
    int  curPage;
    
    UIBarButtonItem *commentItem;
    UIActivityIndicatorView *indicator;
    
    UIImageView *ImgView;
    
     
}

@property (nonatomic, retain) HahaRPC *hahaRPC;
@property (nonatomic, retain) IBOutlet UITableView *commentTableView;
@property (nonatomic, retain) NSMutableArray *dataSource;
@property (nonatomic, retain) HahaCommentItem *comment;
@property (nonatomic, retain) HahaItem *hahahItem;

@property (nonatomic, retain) UIBarButtonItem *commentItem;



@property (nonatomic, assign) BOOL isLoading;



-(UIImage *)imgHandlerFuction:(UIImage *)img;

 

@end
