//
//  MainAppDelegate.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-13.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "MXImageUtils.h"
#import "MXUser.h"
#import "MXAccountManager.h"
#import "MobClick.h"
#import "HahaCore.h"
#import "HahaItemDetailViewController.h"
//@class HahaItemDetailViewController;
@interface MainAppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,MXAccountDelegate,MobClickDelegate>
{
    Reachability *hostReach;
    MXUser *name;
    BOOL isLonIn;
    NSUserDefaults *HahaUserInfo;
    
    UIView *v;
    ///HahaItem *hahaItem1;
    UIView *csView;
    UITextView *textView;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HahaItemDetailViewController *hahaItemVC;



@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong,nonatomic)UINavigationController *navigationController;
@property (nonatomic,retain) Reachability *hostReach;
@property (nonatomic,retain) MXUser *name;
@property (nonatomic, assign) BOOL isLonIn;
///  @property (nonatomic, assign) HahaItem *hahaItem1;
@property (strong, nonatomic) HahaItemDetailViewController *hahaItemVC1;
@property (nonatomic, retain) NSUserDefaults *HahaUserInfo;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIView *csView;

@end
