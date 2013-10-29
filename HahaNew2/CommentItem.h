//
//  CommentItem.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-30.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentItem : UITableViewCell
{
    
    //UI属性
    
    UIImageView *_commentatorIcon;
    UILabel *_commentatorNameLab;
    UILabel *_commentTimeLab;
    UILabel *_commentContentLab;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *commentatorIcon;
@property (nonatomic, retain) IBOutlet UILabel *commenttatorNameLab;
@property (nonatomic, retain) IBOutlet UILabel *commentTimeLab;
@property (nonatomic, retain) IBOutlet UILabel *commentContentLab;

@end;