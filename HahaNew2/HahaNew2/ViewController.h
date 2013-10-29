//
//  ViewController.h
//  HahaNew2
//
//  Created by Li-Qun on 13-10-14.
//  Copyright (c) 2013年 Li-Qun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    IBOutlet UIImageView *imageView;
}
- (IBAction)showCamera:(id)sender;

@end