//
//  CustomTabCell.m
//  HahaNew2
//
//  Created by Li-Qun on 13-9-29.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//


#import "CustomTabCell.h"


@implementation CustomTabCell

@synthesize hahaItemPubTimeLabel ;
@synthesize hahaItemContentLab;
@synthesize praiseBtn  ;
@synthesize praiseCountLabel;
@synthesize contemptBtn;
@synthesize contemptCountLabel;
@synthesize commentImgView ;
@synthesize publisherIcon;
@synthesize publisherNameLabel;
@synthesize indicator ;

@synthesize separateLine ;
@synthesize imgIsLoading ;

/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */
- (void)dealloc
{
    [separateLine release];
    [hahaItemContentLab release];
    [hahaItemPubTimeLabel release];
    [praiseBtn release];
    [praiseCountLabel release];
    [commentCountLabel release];
    [contemptBtn release];
    [contemptCountLabel release];
    [publisherIcon release];
    [publisherNameLabel release];
    [commentImgView release];
    
    [super dealloc];
}
@end
