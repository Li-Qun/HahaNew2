//
//  MXImageUtils.h
//  MxBrowser
//
//  Created by Alex Lee on 11/9/11.
//  Copyright (c) 2011 MAXTHON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXImageUtils : NSObject

//
// 根据指定文件名返回UIImage对象， 
// 如果文件名是9.png格式， 则返回可拉伸图像， 拉伸区域已经自动设置好
// 否则返回普通UIImage对象
//
+ (UIImage *) imageFromFile:(NSString *)filePath;

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (void)UIViewWriteToSavedPhotosAlbum:(UIView *)view;

+ (UIImage *) imageFromColor:(UIColor *)color;

@end

