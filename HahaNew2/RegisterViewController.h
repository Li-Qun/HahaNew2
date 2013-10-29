//
//  RegisterViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-28.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MXAccountManager.h"
@interface RegisterViewController : UIViewController<MXAccountDelegate,UITextFieldDelegate>
{
    UITextField *nameField;
    UITextField *numbField;
    
    IBOutlet UIButton *RegisterButton;
    
    BOOL isRegister;//判断 是否注册成功
    
    MXAccountManager *accountManager;
    
}
@property (nonatomic,retain) IBOutlet UIButton *RegisterButton;
@property (nonatomic,retain) IBOutlet UITextField *nameField;
@property (nonatomic,retain) IBOutlet UITextField *numbField;
@property (nonatomic,retain)MXAccountManager *accountManager;
-(IBAction)textFielDoneEditing:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(IBAction)Press:(id)sender;//注册方法

 

@end
