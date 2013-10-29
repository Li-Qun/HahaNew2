//
//  MXImageUtils.m
//  MxBrowser
//
//  Created by Alex Lee on 11/9/11.
//  Copyright (c) 2011 MAXTHON. All rights reserved.
//

#import "MXImageUtils.h"
//#import "FMDatabase.h"
//#import "MxDataBase.h"

#define MXRangeNotFound NSMakeRange(NSNotFound, 0)

@interface MXImageUtils(NinePatch)

+ (UIImage *) ninePatchImageFromFile:(NSString *) file;
+ (UIImage *) subImageOfImage:(UIImage *)originalImage inRect:(CGRect) rect;
+ (NSRange) rangeOfBlackPiexlInImage:(UIImage *)image vertical:(BOOL)vertical;

#pragma mark - caching
+ (void)cacheNinePatchImage:(UIImage *)image;

@end

@implementation MXImageUtils

static int kBytesPerPixel = 4;
static int kBitsPerComponent = 8;

+ (UIImage *) imageFromFile:(NSString *)filePath
{
    if ([filePath hasSuffix:@".9.png"]) {
        //TODO: add caching later
       // MXLog(@"loading 9.png image: %@", filePath);
        return [self ninePatchImageFromFile:filePath];
    } else {
        return [UIImage imageWithContentsOfFile:filePath];
    }
}

+ (UIImage *) ninePatchImageFromFile:(NSString *) file
{
    UIImage *origImg = [UIImage imageWithContentsOfFile:file];
    if (origImg == nil) {
        return nil;
    }
    NSUInteger w = origImg.size.width;
    NSUInteger h = origImg.size.height;
    UIImage *topImg = [self subImageOfImage:origImg inRect:CGRectMake(1.0f, 0.0f, w - 2.0f, h - 2.0f)];
    UIImage *leftImg = [self subImageOfImage:origImg inRect:CGRectMake(0.0f, 1.0f, w - 2.0f, h - 2.0f)];
    
    UIImage *centerImg = [self subImageOfImage:origImg inRect:CGRectMake(1.0f, 1.0f, w - 2.0f, h - 2.0f)];
    
    NSUInteger leftCapWidth = [self rangeOfBlackPiexlInImage:topImg vertical:NO].location;
    NSUInteger topCapHeight = [self rangeOfBlackPiexlInImage:leftImg vertical:YES].location;
    
    if (leftCapWidth == NSNotFound) leftCapWidth = 0;
    if (topCapHeight == NSNotFound) topCapHeight = 0;
    
    //MXLog(@"%@; left:%d, top:%d", file, leftCapWidth, topCapHeight);
    
    return [centerImg stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
}

+ (UIImage *)subImageOfImage:(UIImage *)originalImage inRect:(CGRect)rect
{
	UIImage *subImage = nil;
	CGImageRef cir = [originalImage CGImage];
	if (cir) {
		rect.origin.x *= originalImage.scale;
		rect.origin.y *= originalImage.scale;
		rect.size.width *= originalImage.scale;
		rect.size.height *= originalImage.scale;
        
		CGImageRef subCGImage = CGImageCreateWithImageInRect(cir, rect);
		if (subCGImage) {
			subImage = [UIImage imageWithCGImage:subCGImage scale:originalImage.scale orientation:originalImage.imageOrientation];
			CGImageRelease(subCGImage);
			MXAssertNilOrIsKindOfClass(subImage,UIImage);
			MXAssertDebug((CGSizeEqualToSize([subImage size], rect.size)), @"Shouldn't get unequal subimage and requested sizes.");
		} else {
			MXLog(@"Couldn't create subImage in rect: '%@'.", NSStringFromCGRect(rect));
		}
	} else {
		MXLog(@"self.CGImage is somehow nil.");
	}
	return subImage;
}

+ (NSRange) rangeOfBlackPiexlInImage:(UIImage *)image vertical:(BOOL)vertical
{
    NSRange blackPixelRange = MXRangeNotFound;
    if (image == nil) {
        return blackPixelRange;
    }
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = image.size;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned int bitmapLength = imageSize.width * imageSize.height * kBytesPerPixel;
    UInt8 *bitmap = (UInt8 *)malloc(bitmapLength);
    memset(bitmap, 0x00, bitmapLength);
    
    int bytesPerRow = kBytesPerPixel * imageSize.width;
    
    CGContextRef context = CGBitmapContextCreate(bitmap, imageSize.width, imageSize.height, kBitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    if (vertical) {
        //V stretch
        for (int vIndex = 1; vIndex < imageSize.height - 1; ++ vIndex) {
            int offset = (vIndex * imageSize.width + 0) * kBytesPerPixel;
            if (bitmap[offset]/* red */ == 0 && 
                bitmap[offset + 1]/* green */ == 0 && 
                bitmap[offset + 2]/* blue */ == 0 && 
                bitmap[offset + 3]/* alpha */ != 0) {
                if (NSNotFound == blackPixelRange.location) {
                    blackPixelRange.location = vIndex;
                }
                ++ blackPixelRange.length;
            }
        }
    } else {
        for (int hIndex = 1; hIndex < imageSize.width - 1; ++ hIndex) {
            int offset = hIndex * kBytesPerPixel;
            if (bitmap[offset]/* red */ == 0 && 
                bitmap[offset + 1]/* green */ == 0 && 
                bitmap[offset + 2]/* blue */ == 0 && 
                bitmap[offset + 3]/* alpha */ != 0) {
                if (NSNotFound == blackPixelRange.location) {
                    blackPixelRange.location = hIndex;
                }
                ++ blackPixelRange.length;
            }
        }
    }
    free(bitmap);
    
    return blackPixelRange;
}

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage; 
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImg = [UIImage imageWithCGImage:masked];
    CGImageRelease(mask);
    CGImageRelease(masked);
    return maskedImg;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)UIViewWriteToSavedPhotosAlbum:(UIView *)view
{
    if(UIGraphicsBeginImageContextWithOptions != NULL)            
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);            
    else 
        UIGraphicsBeginImageContext(view.frame.size);  
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* tmp_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(tmp_image,nil,NULL,NULL);//保存到相簿
}

+ (UIImage *) imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - caching

+ (void)cacheNinePatchImage:(UIImage *)image
{
    static NSString *dbName = @"caches.db";
   // FMDatabase *db = [[MXDataBase getInstance] obtainDBHandlerWithName:dbName];
    
}


@end
