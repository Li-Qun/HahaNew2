//
//  LoginViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "MXAccountManager.h"
#import "MainAppDelegate.h"
#import "HahaCore.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize isBackToTop;
@synthesize isPopToTheTop;
@synthesize RegisterButton;
@synthesize LogInButton;
@synthesize nameField;
@synthesize numbField;
@synthesize accountManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isBackToTop=NO;
        isPopToTheTop=NO;
        
    }
    return self;
}

-(void)userDidLogin
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.isLonIn = YES;
    [app.HahaUserInfo setObject:self.nameField.text forKey:@"userNameStr"];
    [app.HahaUserInfo setObject:self.nameField.text forKey:@"passwordStr"];
    [app.HahaUserInfo setObject:@"yes" forKey:@"autoLogIn"];
    [app.HahaUserInfo synchronize];
    
    
    if (self.isPopToTheTop)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[MXAccountManager shareInstance] getProfile];
}


-(void)userProfileDidChange
{
    MainAppDelegate *app = (MainAppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.HahaUserInfo setObject:[[[MXAccountManager shareInstance] currentUser] nickName] forKey:@"userNickName"];
    [app.HahaUserInfo synchronize];
}

-(void)loginDidFail:(NSDictionary *)info
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"哈哈" message:@"登录失败：帐号不存在或者密码错误" delegate:nil cancelButtonTitle:@"知道" otherButtonTitles: nil];
    [alertView show];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //修改返回按钮
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemReply     target:self   action:@selector(backBtnPress)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    
    
    [leftButton release];
    
    
    self.nameField.placeholder=@"用户名或邮箱";
    self.numbField.placeholder=@"输入6到20位无空格字符";
    self.numbField.secureTextEntry=YES;
    self.nameField.clearButtonMode= UITextFieldViewModeUnlessEditing;
    self.numbField.clearButtonMode= UITextFieldViewModeUnlessEditing;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [RegisterButton release];
    [LogInButton release];
    [super dealloc];
}
-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)LoginPress:(id)sender {//响应登录
    if ([self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [self.nameField Shake];
    }
    
    else if ([self.numbField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [self.numbField Shake];
    }
    else
    {
        [[MXAccountManager shareInstance] setDelegate:self];
        [[MXAccountManager shareInstance] loginAsAccount:self.nameField.text password:self.numbField.text regionDomain:NULL option:MXLoginOptionNone];
    }
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil
    LogInButton = nil;
    RegisterButton = nil;
    nameField = nil;
    self.numbField = nil;
    // self.bigBgImg = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)textFielDoneEditing:(id)sender
{
    [sender resignFirstResponder];
}
-(IBAction)backgroundTap:(id)sender
{
    [nameField resignFirstResponder];
    [numbField resignFirstResponder];
}
-(IBAction)Press:(id)sender{
    RegisterViewController *registerVC = [[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:registerVC animated:YES];
}
@end