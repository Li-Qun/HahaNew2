//
//  SuggestionViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-10-2.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestionViewController : UIViewController<UITextViewDelegate,UIAlertViewDelegate>
{
    IBOutlet UIButton *submitBtn;
    IBOutlet UITextView *contentTV;
    
     //BOOL textViewStyle;    //用于判断textview是否为展开状态   YES代表展开状态
}
@property (nonatomic, assign) BOOL textViewStyle;
-(IBAction)submitBtnPress :(id)sender;


@end
