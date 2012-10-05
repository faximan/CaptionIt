//
//  MainViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/TWTweetComposeViewController.h>

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@end
