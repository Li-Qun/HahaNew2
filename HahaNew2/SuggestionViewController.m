//
//  SuggestionViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-10-2.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "SuggestionViewController.h"

#import "MXImageUtils.h"
#import "HahaCore.h"
#import "MobClick.h"

@implementation SuggestionViewController

@synthesize textViewStyle;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"反馈";
    //创建 
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemReply     target:self   action:@selector(clickLeftButton1)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    
    
    [leftButton release];
        
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"评论"
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector (backBtnPress)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.hidesBackButton =YES;
        self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];//*/
 
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [contentTV becomeFirstResponder];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//textView delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
     
        textView.text = @"";
}



 

-(IBAction)submitBtnPress:(id)sender
{
    NSLog(@"text ============= %@",contentTV.text);
    if ([contentTV.text length] == 0)
    {
        [contentTV Shake];
    }
    
    else
    {
        NSString *str = [[NSString alloc] initWithFormat:@"%@",contentTV.text];
        NSDictionary *feedBackDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"UMengFeedbackGender",@"2",@"UMengFeedbackAge",str,@"UMengFeedbackContent",nil];
        [MobClick feedbackWithDictionary:feedBackDictionary];//借口 传入评论~
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickLeftButton1
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
