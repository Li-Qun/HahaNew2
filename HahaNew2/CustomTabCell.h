//
//  CustomTabCell.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabCell : UITableViewCell{
    
    
    IBOutlet UILabel *hahaItemPubTimeLabel;//时间
    IBOutlet UILabel *hahaItemContentLab;//评论
    
    
    IBOutlet UIButton *praiseBtn;//赞
    IBOutlet UILabel *praiseCountLabel;//赞数量
    
    IBOutlet UIButton *contemptBtn;//踩
    IBOutlet UILabel *contemptCountLabel;//踩数量
    
    IBOutlet UIImageView *publisherIcon;//发表者肖像
    IBOutlet UILabel *publisherNameLabel;//名字
    
    IBOutlet UIImageView *commentImgView;//评论
    IBOutlet UILabel *commentCountLabel;//评论数量
    
    
    IBOutlet UIImageView *separateLine;
    
    BOOL imgIsLoading;
    
    //  */
    
    
}

@property (nonatomic, retain) UILabel *hahaItemPubTimeLabel;
@property (nonatomic, retain) UILabel *hahaItemContentLab;

@property (nonatomic, retain) UIButton *praiseBtn;
@property (nonatomic, retain) UILabel *praiseCountLabel;

@property (nonatomic, retain) UIButton *contemptBtn;
@property (nonatomic, retain) UILabel *contemptCountLabel;
@property (nonatomic, retain) UIImageView *commentImgView;
@property (nonatomic, retain)IBOutlet UILabel *commentCountLabel;//评论数量


@property (nonatomic, retain) UIImageView *publisherIcon;
@property (nonatomic, retain) UILabel *publisherNameLabel;



@property (nonatomic, retain) UIImageView *separateLine;


@property (nonatomic, assign) BOOL imgIsLoading;


@property (nonatomic, retain) UIActivityIndicatorView *indicator;
//*/
@end
