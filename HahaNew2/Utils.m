//
//  Utils.m
//  MXAccount
//
//  Created by Alex Lee on 2/7/12.
//  Copyright (c) 2012 Maxthon_. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Utils

+ (NSString *) userPreferredLanguage
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [userDefault objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (NSString *) SHA256Encode:(NSString *)src
{
    unsigned char hashedChars[32];
    NSData * inputData = [src dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA256(inputData.bytes, inputData.length, hashedChars);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i=0; i<32; i++) {
        [result appendString:[NSString stringWithFormat:@"%02x",hashedChars[i]]];
    }
    
    return [result autorelease];
}

@end
