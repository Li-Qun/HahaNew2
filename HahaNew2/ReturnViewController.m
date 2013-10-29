//
//  ReturnViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-10-2.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "ReturnViewController.h"
#import "SuggestionViewController.h"
#import "MXImageUtils.h"
#import "MainAppDelegate.h"
#import "LoginViewController.h"
#import "MXAccountManager.h"
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
@interface ReturnViewController ()

@end

@implementation ReturnViewController
@synthesize name;
@synthesize Advice;
@synthesize putUp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //修改返回按钮
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemReply     target:self   action:@selector(backBtnPress)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    
    
    [leftButton release];

    
    self.title = @"反馈";
    [name initWithFrame:CGRectMake(15, 9, 260, 20)];
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app.isLonIn)
    {
        self.putUp.enabled=NO;
        
        self.putUp.tintColor=[UIColor redColor];

        self.putUp.titleLabel.text=@"登 录";
        
        self.putUp.titleLabel.textColor=[UIColor redColor];
        
        name .text = [NSString stringWithFormat:@"昵称 ：%@",[app.HahaUserInfo valueForKey:@"userNickName"]];
    }
    else
    {
        self.putUp.enabled=YES;
        name .text = [NSString stringWithFormat:@"昵称 ：      "];
    }
    [name setFont:[UIFont systemFontOfSize:15]];
    [name setTextColor:RGBCOLOR(100, 104, 109)];
    [self.view addSubview:name];
    [name release];
    
    [email initWithFrame:CGRectMake(15, 48, 260, 20)];
     if(app.isLonIn)
     {
        email. text = [NSString stringWithFormat:@"邮箱 ：%@",[app.HahaUserInfo valueForKey:@"userNameStr"]]; 
     }
     else
     {
        email. text = [NSString stringWithFormat:@"邮箱 ：      "]; 
     }
         
    [email setFont:[UIFont systemFontOfSize:15]];
    [email   setTextColor:RGBCOLOR(100, 104, 109)];
    [self.view addSubview:email];
    [email release];


}


- (void)dealloc {
    [name release];
    [email release];
    [Advice release];
    [self.putUp release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidAppear:(BOOL)animated
{//视图已完全过渡到屏幕上时调用
     
    [super viewDidAppear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)PutUp:(id)sender{
    
    LoginViewController  *VC1=[[[LoginViewController alloc]init]autorelease];
    [self.navigationController pushViewController:VC1 animated:YES];
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;
}

-(IBAction)logOutBtnPress:(id)sender
{
    //注销按钮
     MainAppDelegate *app = (MainAppDelegate *) [[UIApplication sharedApplication] delegate];
    [[MXAccountManager shareInstance] logoutAndClearUserData:YES];
    app.isLonIn = NO;
    [app.HahaUserInfo setObject:@"no" forKey:@"autoLogIn"];

    LoginViewController  *VC1=[[LoginViewController alloc]init];//一释放就崩溃
    [self.navigationController pushViewController:VC1 animated:YES];
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;
}
-(IBAction)feedBackBtnPress:(id)sender
{
    //反馈
    SuggestionViewController *VC1=[[[SuggestionViewController alloc]init]autorelease];
    [self.navigationController pushViewController:VC1 animated:YES];
    self.navigationItem.rightBarButtonItem.customView.hidden = NO;

}

@end

