//
//  CommentItem.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-30.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "CommentItem.h"

@implementation CommentItem

@synthesize commentatorIcon;
@synthesize commenttatorNameLab;
@synthesize commentTimeLab;
@synthesize commentContentLab;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
