//
//  PublishOrCommentViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HahaCore.h"

//#import "UIExpandingTextView.h"

@interface PublishOrCommentViewController : UIViewController<HahaDelegate,UITextViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITextView *myConmmentTextView;//文本
    //UIButton *transmitBtn;//提交
    IBOutlet UIImageView *bgImgView;
    IBOutlet UIButton *transmitBtn;
    
    BOOL textViewStyle;    //用于判断textview是否为展开状态   YES代表展开状态
    BOOL writeOrCommentHaha;  // 用语判断页面是用语发表一个haha，还是评论一个哈哈     YES代表是发布一条哈哈  NO代表是评论一个哈哈；
    
    NSString *myConmmetStr;
    NSString *itemID;
    NSString *userID;
    NSString *respondID;
    
    UIImageView *BGimageView;
    HahaRPC *hahaRPC;
    
    UIImagePickerController *imagePicker;
    IBOutlet UIImageView *imageView;
    UIView *keyBoardView;
    UIView *pictureBoardView;
    BOOL isKeyBoard;
    BOOL isFirst;
    BOOL isCamera;
    UIScrollView *scrollView;
    ////获取图片本地
    UIImagePickerController *imgPickerCtrller;//调用图片的核心类
    UIImageView *photoImageView;//是指向xib文件中Image View 用的。
    UIActionSheet *actionSheet;
}

@property (nonatomic, retain) UIImagePickerController *imgPickerCtrller; 
@property (nonatomic, retain) UITextView *myConmmentTextView;
@property (nonatomic, retain) UIButton *transmitBtn;
@property (nonatomic, retain) UIImageView *bgImgView;

@property (nonatomic, retain) NSString *myConmmetStr;
@property (nonatomic, retain) NSString *itemID;
@property (nonatomic, retain) NSString *userID;

@property (nonatomic, assign) BOOL textViewStyle;
@property (nonatomic, assign) BOOL writeOrCommentHaha;

@property (nonatomic, retain) HahaRPC *hahaRPC;
@property (nonatomic, retain) UIImageView *BGimageView;


-(IBAction)submitBtnPressed:(id)sender;
//- (IBAction)showCamera:(id)sender;
@end

