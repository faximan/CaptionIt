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
@synthesize textLabel = _textLabel;

@synthesize stampedImage = _stampedImage;

#pragma mark For sharing the image

// Takes the current addons to the image and renders it to a bitmap
- (UIImage *)renderCurrentImage
{
    // Get the context
    UIGraphicsBeginImageContext(_imageView.bounds.size);
    
    // Render the image
    [_imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Render the text on top of the image
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), _textLabel.frame.origin.x, _textLabel.frame.origin.y);
    [_textLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Convert to UIImage
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return bitmap;
}

// Called when the user finishes saving an image to the photos album
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary *)contextInfo
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

- (void)emailImage:(UIImage *)imageToShare
{
    // Convert the image to a PNG representation for emailing
    NSData *imageData = UIImagePNGRepresentation(imageToShare);
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

- (void)shareImage:(UIImage *)imageToShare viaSocialService:(NSString *)serviceType;
{
    SLComposeViewController *socialComposer = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    
    // Add the image
    [socialComposer addImage:imageToShare];
    
    // Print out diagnostic information when the user
    //completes the action and dismiss the view controller.
    [socialComposer setCompletionHandler:
     ^(SLComposeViewControllerResult result)
     {
         switch (result)
         {
             case SLComposeViewControllerResultCancelled:
                 NSLog(@"%@ Result: Cancel", serviceType);
                 break;
             case SLComposeViewControllerResultDone:
                 NSLog(@"%@ Result: Sent", serviceType);
                 break;
             default:
                 NSLog(@"%@ Result: Error", serviceType);
                 break;
         }
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    [self presentViewController:socialComposer animated:YES completion:nil];
}

#pragma mark For editing the image
- (IBAction)addText
{
    // Set the textlabel to be in edit mode
    [_textLabel becomeFirstResponder];
}

#pragma mark UITextField delegate

// Called when the UITextField is in edit mode and return key is hit
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark View Stuff
/** Delegate method called when the user selects an option in an action sheet. */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Prepare the picture for sharing
    UIImage *imageToShare = [self renderCurrentImage];
    if (!imageToShare)
    {
        [self showAlertWithTitle:@"Error" andMessage:@"Your picture could not be prepared properly for sharing"];
        return;
    }
    switch (buttonIndex)
    {
        case 0: // save to camera
            UIImageWriteToSavedPhotosAlbum(imageToShare, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            break;
        case 1: // email
            [self emailImage:imageToShare];
            break;
        case 2: // Facebook
            [self shareImage:imageToShare viaSocialService:SLServiceTypeFacebook];
            break;
        case 3: // Twitter
             [self shareImage:imageToShare viaSocialService:SLServiceTypeTwitter];
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
    
    _stampedImage = [[StampedImage alloc] init];
    _textLabel.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set the imageview to be the image that was selected
    if (!_stampedImage.originalImage)
    {
        // The image is not set for some reason, go back
        [self showAlertWithTitle:@"Error" andMessage:@"The image you selected is not available."];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _imageView.image = _stampedImage.originalImage;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
