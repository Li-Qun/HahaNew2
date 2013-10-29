//
//  ReturnViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-10-2.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReturnViewController : UIViewController

{
//    IBOutlet UIImageView *backgroundImg;
//    IBOutlet UIImageView *labelBackgroundImg;
//     IBOutlet UIButton *feedBackBtn;
//    IBOutlet UIImageView *line;
//
//    UILabel *_feedbackBtnLabel;
/////////////////////////////////
    IBOutlet UILabel *name;
    IBOutlet UILabel *email;
    
    IBOutlet UIButton *Advice;
    IBOutlet UIButton *logOutBtn;

    
    //IBOutlet UIButton *putUp;//设置登录键自定义
}
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UIButton *Advice;



@property (retain, nonatomic) IBOutlet UIButton *putUp;
- (IBAction)PutUp:(id)sender;


-(IBAction)logOutBtnPress:(id)sender;//注销
-(IBAction)feedBackBtnPress:(id)sender;//反馈

@end
