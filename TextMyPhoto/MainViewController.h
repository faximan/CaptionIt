//
//  MainViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) UIImagePickerController *imgPicker;

-(IBAction)shareButtonPressed:(UIButton *)sender;
-(IBAction)choosePhotoButtonPressed:(UIButton *)sender;

@end
