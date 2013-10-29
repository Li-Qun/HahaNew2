//
//  RegisterViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-28.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//


#import "RegisterViewController.h"
#import "HahaCore.h"
@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize nameField;
@synthesize numbField;
@synthesize RegisterButton;
@synthesize accountManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title=@"注册哈哈";
        
        [accountManager setDelegate:self];
        isRegister=NO;
    }
    return self;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//*********************注册结果 回调****************//
-(void)handleSignupResult:(NSDictionary *)info
{
    //   HahaRPC   *rpc= [[HahaRPC alloc]init];
    //  int num=[rpc publishHahaItem:@"This is a Haha API"];
    NSString *alertStr = [[NSString alloc] init];
    NSString *responceStr = [[NSString alloc] initWithFormat:@"%@",[info valueForKey:@"errorMessage"]];
    NSLog(@"%@",responceStr);
    if ([responceStr isEqualToString:@"email_error"])
    {
        alertStr = @"帐号错误";
        isRegister = NO;
    }
    else if([responceStr isEqualToString:@"param_error"])
    {
        alertStr = @"密码格式错误/n请输入6到20位以内字符，不能使用空格";
        isRegister = NO;
    }
    else if([responceStr isEqualToString:@"email_exist"])
    {
        alertStr = @"帐号已经存在";
        isRegister = NO;
    }
    else
    {
        alertStr = @"注册成功，请登录";
        isRegister = YES;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册" message:alertStr delegate:self cancelButtonTitle:@"知道" otherButtonTitles:nil];
    NSLog(@"XXXXX\n %@ \n",alertStr);
    [alert show];
    [alert release];
    [alertStr release];
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
    
}

-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
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
-(void)dealloc
{
    [nameField release];
    [numbField release];//because has "retain" so must release
    [RegisterButton release];
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

-(void)Press:(id)sender
{
    if ([self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [self.nameField Shake];
    }
    
    else if ([self.numbField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        [self.numbField Shake];
    }
    else//********************满足不为空的条件后   向接口传入账号、密码、文本信息
    {
        [[MXAccountManager shareInstance] setDelegate:self];
        [[MXAccountManager shareInstance] singupAccount:self.nameField.text password:self.numbField.text];
    }//*/
    NSLog(@"\n%@\n%@\n%d\n",self.nameField.text,numbField.text,isRegister);
}


-(void)alertView:(UIAlertView *)alertView
{
    if(isRegister)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)LogInPress:(id)sender {
}
@end