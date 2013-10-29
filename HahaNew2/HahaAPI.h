//
//  HahaAPI.h
//  HahaNew2
//
//  Created by Li-Qun on 13-9-17.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HahaAPI : NSObject

+ (id)sharedInstance;

- (NSInteger)publishHaha:(NSString *)message;
//-(void)publishHahaItem:(NSString *)itemContent;
@end
