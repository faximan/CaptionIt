//
//  EditViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "EditViewController.h"

@implementation EditViewController

@synthesize imageView = _imageView;


#pragma mark For sharing the image

// Called when the user finishes saving an image to the photos album
- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(NSDictionary *)contextInfo
{
    if (error != NULL)
        [self showAlertWithTitle:@"Unknown error" andMessage:@"The image was not saved, sorry."];
    else // no errors
        [self showAlertWithTitle:@"Success" andMessage:@"The image was successfully saved to your photos album."];
}

/** Share the image to the world. Possible ways of sharing:
 * Save to photo album
 * Email it
 * Facebook
 * Twitter
 * other? */
-(void)shareButtonPressed
{    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"How do you want to share the image?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to photo library", @"Email", @"Facebook", @"Twitter", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)emailImage
{
    // Convert the image to a PNG representation for emailing
    NSData *imageData = UIImagePNGRepresentation(_imageView.image);
    if (!imageData)
    {
        // Something went wrong, the image was probably not set
        [self showAlertWithTitle:@"Error" andMessage:@"Something went wrong when preparing the image for sharing via email."];
        return;
    }
    
    // Check to make sure that this device is capable of sending emails
    if ([MFMailComposeViewController canSendMail])
    {
        NSLog(@"Trying to send mail");
        // Share the picture via email
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"My stamped photo"];
        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"myphoto"];
        if (controller)
            [self presentModalViewController:controller animated:YES];
    }
    else
        [self showAlertWithTitle:@"Error" andMessage:@"Your device is not configured for sending emails!"];
}

// Called when the user exits the mail composer window
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
        NSLog(@"Mail sent");
    else
        NSLog(@"Mail not sent");
    [self dismissModalViewControllerAnimated:YES];
}

- (void)shareImageViaTwitter
{
    // Make sure this device is capable of tweeting.
    if (![TWTweetComposeViewController canSendTweet])
    {
        [self showAlertWithTitle:@"Error" andMessage:@"Your device is not properly configured for sending tweets."];
    }
    else
    {
        TWTweetComposeViewController* tweetComposer = [[TWTweetComposeViewController alloc] init];
        
        // Add the image to the tweet
        [tweetComposer addImage:_imageView.image];
        
        // Print out diagnostic information when the user
        // completes the action and dismiss the ModalViewController
        TWTweetComposeViewControllerCompletionHandler
        completionHandler =
        ^(TWTweetComposeViewControllerResult result)
        {
            switch (result)
            {
                case TWTweetComposeViewControllerResultCancelled:
                    NSLog(@"Twitter Result: Cancel");
                    break;
                case TWTweetComposeViewControllerResultDone:
                    NSLog(@"Twitter Result: Sent");
                    break;
                default:
                    NSLog(@"Twitter Result: Error");
                    break;
            }
            [self dismissModalViewControllerAnimated:YES];
        };
        [tweetComposer setCompletionHandler:completionHandler];
        [self presentModalViewController:tweetComposer animated:YES];
    }
}

#pragma mark View Stuff
/** Delegate method called when the user selects an option in an action sheet. */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!_imageView.image)
    {
       [self showAlertWithTitle:@"Error" andMessage:@"You are not able to share this image."];
            return;
    }
    switch (buttonIndex)
    {
            case 0: // save to camera
                UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                break;
            case 1: // email
                [self emailImage];
                break;
            case 2: // Facebook
                NSLog(@"Facebook");
                break;
            case 3: // Twitter
                [self shareImageViaTwitter];
                break;
            case 4: // cancel - do nothing
                return;
    }
}

// Show a UIAlertView with the passed title and message
// Only one button called "OK" is added to dissmiss the alert.
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Edit";
    
    // Add share button to navigation bar
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(shareButtonPressed)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:buttonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
