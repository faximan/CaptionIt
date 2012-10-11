//
//  EditViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/Social.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "StampedImage.h"
#import "MNColorPicker.h"

@interface EditViewController : UIViewController < UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, MNColorPickerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textLabel;
@property (nonatomic, weak) IBOutlet UIView *parentView; // The view that contains the picture and all the addons.

@property (nonatomic, strong) StampedImage *stampedImage;

- (void)shareImage:(UIImage *)imageToShare viaSocialService:(NSString *)serviceType;
- (void)emailImage:(UIImage *)imageToShare;

- (IBAction)addText;
- (IBAction)changeColor;

@end
