//
//  EditViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/TWTweetComposeViewController.h>

@interface EditViewController : UIViewController < UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

// Share the current image (in imageView) to Twitter
- (void)shareImageViaTwitter;

// Email the current image (in imageView)
- (void)emailImage;

@end
