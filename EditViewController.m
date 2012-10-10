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
        [self showAlertWithTitle:@"Success" andMessage:@"The image was successfully saved to your photo album."];
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
            [self presentViewController:controller animated:YES completion:nil];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareImageViaTwitter
{
    SLComposeViewController* tweetComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
    // Add the image to the tweet
    [tweetComposer addImage:_imageView.image];
        
    // Print out diagnostic information when the user
    // completes the action and dismiss the view controller.
    [tweetComposer setCompletionHandler:
    ^(SLComposeViewControllerResult result)
    {
        switch (result)
        {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: Cancel");
                break;
            case SLComposeViewControllerResultDone:
                NSLog(@"Twitter Result: Sent");
                break;
            default:
                NSLog(@"Twitter Result: Error");
                break;
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:tweetComposer animated:YES completion:nil];
}

- (void)shareImageViaFacebook
{
    SLComposeViewController *fb = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    // Add the image
    [fb addImage:_imageView.image];
    
    // Print out diagnostic information when the user
    //completes the action and dismiss the view controller.
    [fb setCompletionHandler:
     ^(SLComposeViewControllerResult result)
     {
         switch (result)
         {
             case SLComposeViewControllerResultCancelled:
                 NSLog(@"Facebook Result: Cancel");
                 break;
             case SLComposeViewControllerResultDone:
                 NSLog(@"Facebook Result: Sent");
                 break;
             default:
                 NSLog(@"Facebook Result: Error");
                 break;
         }
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    [self presentViewController:fb animated:YES completion:nil];
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
                [self shareImageViaFacebook];
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
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(shareButtonPressed)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:buttonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
