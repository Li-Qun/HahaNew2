//
//  Utils.h
//  MXAccount
//
//  Created by Alex Lee on 2/7/12.
//  Copyright (c) 2012 Maxthon_. All rights reserved.
//

#import "MXSingleton.h"

@interface Utils : NSObject

+ (NSString *) userPreferredLanguage;

+ (NSString *) SHA256Encode:(NSString *) src;
@end
