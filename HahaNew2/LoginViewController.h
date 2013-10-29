//
//  LoginViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MXAccountManager.h"
@interface LoginViewController : UIViewController<MXAccountDelegate,UITextFieldDelegate>
{
    
    UITextField *nameField;
    UITextField *numbField;
    
    IBOutlet UIButton *RegisterButton;
    IBOutlet UIButton *LogInButton;
    BOOL isLogin;//判断 是否登录成功
    
    MXAccountManager *accountManager;
    BOOL isPopToTheTop;
    BOOL isBackToTop;
}

@property (nonatomic, assign) BOOL isBackToTop;
@property (nonatomic, assign) BOOL isPopToTheTop;


@property (retain, nonatomic) IBOutlet UIButton *LogInButton;
@property (nonatomic,retain) IBOutlet UIButton *RegisterButton;
@property (nonatomic,retain) IBOutlet UITextField *nameField;
@property (nonatomic,retain) IBOutlet UITextField *numbField;
@property (nonatomic,retain)MXAccountManager *accountManager;


-(IBAction)textFielDoneEditing:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(IBAction)Press:(id)sender;//进入注册页面
- (IBAction)LoginPress:(id)sender;
@end
