//
//  PublishOrCommentViewController.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "PublishOrCommentViewController.h"

#import "MXImageUtils.h"
#import "MXAccountManager.h"
#import "QuartzCore/QuartzCore.h"
#import "MainAppDelegate.h"

#define Time  0.25
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  keyboardHeight 216
#define  toolBarHeight 45
#define  choiceBarHeight 35
#define  facialViewWidth 300
#define facialViewHeight 170
@interface PublishOrCommentViewController ()

@end

@implementation PublishOrCommentViewController

@synthesize imgPickerCtrller;
@synthesize myConmmentTextView;
@synthesize transmitBtn;
@synthesize myConmmetStr;
@synthesize itemID;
@synthesize userID;
@synthesize hahaRPC;
@synthesize textViewStyle;
@synthesize writeOrCommentHaha;
@synthesize bgImgView ;
@synthesize BGimageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        //[self.tabBarController.tabBar setHidden:YES];
        textViewStyle = NO;
        isFirst=YES;
        isKeyBoard=YES;
        hahaRPC = [[HahaRPC alloc] init];
        [hahaRPC setDelegate: self];
        itemID = [[NSString alloc] init];
        userID = [[NSString alloc] init];
        myConmmetStr = [[NSString alloc] init];
        
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)notifyCommendHahaEndWithResponseID:(NSString *)ID
{
    if ([ID isEqualToString:@"1"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"哈哈" message:@"操作已成功" delegate:self cancelButtonTitle:@"知道" otherButtonTitles: nil];
        
        [alert show];
    }
}
-(void)notifyLoadFail
{
    
}
-(void)notifyLoadStart
{
    
}
////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    //修改返回按钮
    UIBarButtonItem *leftButton=[[UIBarButtonItem alloc]  initWithBarButtonSystemItem: UIBarButtonSystemItemReply     target:self   action:@selector(backBtnPress)];
    
    
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.hidesBackButton =YES;
    
    [leftButton release];
    
    
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
     [topView setBarStyle:UIBarStyleBlack];
    //定义两个flexibleSpace的button，放在toolBar上，这样完成按钮就会在最右边
    UIBarButtonItem * flexibleItem =[[UIBarButtonItem  alloc]initWithBarButtonSystemItem:                                        UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *  PicItem = [[UIBarButtonItem  alloc]initWithTitle:@"贴图" style: UIBarButtonItemStyleBordered target:self action:@selector(selectExistingPicture)];
    UIBarButtonItem * faceButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"FaceBig"]style:UIBarButtonItemStylePlain target:self action:@selector(showFace)];
   
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleBordered  target:self action:@selector(resignKeyboard)];
    //在toolBar上加上这些按钮
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:  PicItem,flexibleItem,faceButtonItem,flexibleItem,doneButton,nil];
    [topView setItems:buttonsArray];
    //PicItem.enabled=NO;
    [flexibleItem release];
    [PicItem release];
    [doneButton release];
    [faceButtonItem release];
    [myConmmentTextView setInputAccessoryView:topView];
   
    
    if(self.writeOrCommentHaha)//写一条哈哈文本
    {
        self.title=@"发表哈哈";
        myConmmentTextView.text=@"写一条哈哈文本";
    }
    else//对哈哈内容进行评论
    {
        self.title=@"评论哈哈";
        myConmmentTextView.text=@"写一条哈哈评论";
    }
  
    myConmmentTextView.inputView=nil;
    myConmmentTextView.inputView = UIKeyboardAppearanceDefault;//键盘类型
    keyBoardView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 216)];
    keyBoardView.backgroundColor=[UIColor whiteColor];
    
    myConmmentTextView.layer.borderWidth =1.2;
    myConmmentTextView.layer.borderColor=[[UIColor whiteColor]CGColor];
    
    [myConmmentTextView setFrame:CGRectMake(11, 10, 298, 350)];
    [myConmmentTextView.layer setCornerRadius:10];//设为圆角矩形框
    self.myConmmentTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    [myConmmentTextView becomeFirstResponder];
    
    
    
    
    //创建表情键盘 face-->keyBoardView
    //scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,216)];
    //[scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"facesBack"]]];
    
    UIButton *face1=[UIButton buttonWithType:UIButtonTypeCustom];
    face1.frame=CGRectMake(0,80, 45, 45);
   
    [face1 setImage:[UIImage imageNamed:@"e417"]forState:UIControlStateNormal];
    
    [face1 addTarget:self action:@selector(face1Press) forControlEvents:UIControlEventTouchUpInside ];
    keyBoardView.backgroundColor=[UIColor lightGrayColor];
    [keyBoardView addSubview:face1];

   
    ///////选取图片 ------>UIActionSheet
     
    //声明 UIImagePickerController实例
    if(imgPickerCtrller==nil)
    {
        UIImagePickerController *ImgPickerCtrller=[[UIImagePickerController alloc]init];
        imgPickerCtrller =ImgPickerCtrller;
        imgPickerCtrller.delegate=self;
    }
    photoImageView=[[UIImageView alloc]init];
    actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"选择图片路径"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"本地图片"
                                  otherButtonTitles:@"拍照",nil];
   
    
    UIButton *submit = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 80, 44)];
    [submit  setFrame:CGRectMake(231,223,78,44)];
    [submit setTitle:@"提交" forState:UIControlStateNormal];
   
}
-(void)viewDidUnload
{
    myConmmentTextView=nil;
    transmitBtn=nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:NO];
}

-(void)dealloc
{
    [itemID release];
    [userID release];
    [myConmmetStr release];
    [hahaRPC release];
    [imgPickerCtrller release];
    [transmitBtn release];
    [super dealloc];
}


-(void)backBtnPress
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)submitBtnPressed:(id)sender
{ 
 
    if ([self.myConmmentTextView.text length] == 0)
    {
        [self.myConmmentTextView Shake];
    }
    else
    {
        if (self.writeOrCommentHaha)
        {
            int response=[self.hahaRPC publishHahaItem:self.myConmmentTextView.text];
            if(response!=1)
                [self respondingComment:response];
           
        }
        else
        {
            id response=[self.hahaRPC  doRemark:self.itemID withContent:self.myConmmentTextView.text
                                         byUser:[[[MXAccountManager shareInstance] currentUserId] stringValue]];
            if((int)response!=1)
            [self respondingComment:(int)response];
        }
    }
   
    NSLog(@"++++%@****%@***%@",self.itemID,[[[MXAccountManager shareInstance] currentUserId] stringValue],self.myConmmentTextView.text );
}
-(void)respondingComment:(int )ID
{
    NSString *Message=[[NSString alloc]init];
    if(ID==0)
    {
        Message=@"服务器端出错";
    }
    else if(ID==2)
    {
        Message=@"用户未登录或已被屏蔽";
    }
    else if(ID==3)
    {
        Message=@"呀〜含有敏感过滤词";
    }
    else if(ID==5)
    {
        Message=@"您讲的太快了，休息一下吧〜";
    }
    else if(ID==6)
    {
        Message=@" ------fail";
    }
    else if(ID==7)
    {
        Message=@"服务器会返回响应码未知";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"哈哈" message:Message delegate:self cancelButtonTitle:@"知道" otherButtonTitles: nil];
    
    [alert show];
    [Message release];
}
//textView delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{//把回车键当做退出键盘的响应手段~
    
    if ([text isEqualToString:@"\n"])
    {
        
        [myConmmentTextView setFrame:CGRectMake(11, 35, 298, 300)];
        [transmitBtn setFrame:CGRectMake(239, 415, 70, 33)];
        
        
        [textView resignFirstResponder];
        
        self.textViewStyle = YES;
        
        return NO;
    }
    
    return YES;
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textViewStyle)
    {
        [myConmmentTextView setFrame:CGRectMake(11, 55, 298, 110)];
        [transmitBtn setFrame:CGRectMake(221, 392, 78, 44)];
        
        textView.text = @"";
    }
}


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
//隐藏键盘
-(void)resignKeyboard
{
    
    [myConmmentTextView setFrame:CGRectMake(11, 35, 298, 300)];
    [transmitBtn setFrame:CGRectMake(239, 415, 70, 33)];
    [myConmmentTextView resignFirstResponder];
    
    self.textViewStyle = YES;
    
    if(!isFirst)
    {
        myConmmentTextView .clearsContextBeforeDrawing=NO;
        
    }
    isFirst=NO;
}

/************获取图片 本地、拍照、取消*********/
#pragma mark -
#pragma mark actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsImageEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:picker animated:YES];//这句是进入相册选图片的语句。
                
                [picker release];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"访问图片库错误"                              message:@""
                                      delegate:nil
                                      cancelButtonTitle:@"OK!"                              otherButtonTitles:nil];
                [alert show];
                [alert release];
            }

            break;
        case 1:
            NSLog(@"click at index %d，暂无拍照功能", buttonIndex);
            break;
        case 2:
            NSLog(@"click at index %d，取消操作", buttonIndex);
            break;
        default:
            NSLog(@"unknown： click at index %d", buttonIndex);
            break;
    }
}
//该方法已经可以进入选取图片了，但选完之后该图片并不显示
//按钮响应方法
- (void)selectExistingPicture
{
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
     
}
//再调用以下委托：实现代理方法，使选中的图片显示在ImageView中
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    photoImageView.frame=CGRectMake(0, 0, 45, 45);
    [myConmmentTextView addSubview:photoImageView];
    photoImageView .image = image; //imageView为自己定义的UIImageView
    [picker dismissModalViewControllerAnimated:YES];
}


/************获取图片 本地、拍照、取消*********/


-(void)showFace
{
    if(!isKeyBoard)
    {
        [myConmmentTextView resignFirstResponder];
        myConmmentTextView.inputView=UIKeyboardAppearanceDefault;
        [myConmmentTextView becomeFirstResponder];
        isKeyBoard=YES;
    }
    else
    {
        [myConmmentTextView resignFirstResponder];
        myConmmentTextView.inputView=keyBoardView;
        [myConmmentTextView becomeFirstResponder];
        isKeyBoard=NO;
    }
      
}


-(void)face1Press
{
    NSString *s =  @"[摇头]";
    [myConmmentTextView becomeFirstResponder];
    myConmmentTextView.text= [myConmmentTextView.text stringByAppendingString:s];
    
    NSLog(@"XXXXXX%@",myConmmentTextView.text);
}
@end
