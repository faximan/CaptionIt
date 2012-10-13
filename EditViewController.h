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

@property (nonatomic, strong) StampedImage *stampedImage;
@property  NSNumber* projectNbr; // The index of this project

@end

/** TODO:
Rendered image i tableviewn
Ta bort bilder ur tableviewn (kryss?)
*/