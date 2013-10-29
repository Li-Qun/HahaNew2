//
//  MXSingleton.h
//  MxBrowser
//
//  Created by Alex Lee on 1/2/12.
//  Copyright (c) 2012 MAXTHON. All rights reserved.
//
//  ©Jean-Luc Pedroni
//
//  Created by Jean-Luc Pedroni on 12/05/08.
//  Mail: jeanluc.pedroni AT free.fr
//
//  Code provided as is, without warranty.
//  You can use it as you wish,
//  but please keep this header.
//
//  NOTE: This class named as "NSSingleton" before, but "NS" is reserved by Apple, so I changed it to "MXSingleton" -- Alex Lee.

#import <Foundation/Foundation.h>

@interface MXSingleton : NSObject

// Deux cas:
// . [NSSingleton cleanup]  : Free all singletons.
// . [MySingleton cleanup] : Free MySingleton.
+(void)cleanup;

// Notes :
// . +(id)sharedInstance can be overridden to return the right type..
//   ex : (MySingleton *)sharedInstance { return [super sharedInstance]; }
// . Singleton initialization must be done as usual in -(id)init.
//
+(id)sharedInstance;


// Notes : juest for subclasses, DO NOT call it outside!!!
- (void) singletonDealloc;

@end
