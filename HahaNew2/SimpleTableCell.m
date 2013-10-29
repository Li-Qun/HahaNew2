//
//  SimpleTableCell.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell

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
