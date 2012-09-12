//
//  MainViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController
{
    bool cameraAvailable;
}

enum actionSheetType
{
    ACTIONSHEET_TYPE_CHOOSE_ORIGIN,
    ACTIONSHEET_TYPE_CHOOSE_SHARE
};

@synthesize imageView = _imageView;
@synthesize shareButton = _shareButton;
@synthesize imgPicker = _imgPicker;

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
-(IBAction)shareButtonPressed:(UIButton *)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"How do you want to share the image?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to photo library", @"Email", @"Facebook", @"Twitter", nil];
    popupQuery.tag = ACTIONSHEET_TYPE_CHOOSE_SHARE;
    
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
        [self showAlertWithTitle:@"Error" andMessage:@"Something went wrong"];
        return;
    }
    
    // Check to make sure that this device is capable of sending emails
    if ([MFMailComposeViewController canSendMail])
    {
        NSLog(@"Trying to send mail");
        // Share the picture via email
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"My texted photo"];
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

#pragma mark For selecting the image

// The device has a camera, return if it should be used for
// getting the image or if it should be picked from the photo library.
-(void)selectSourceTypeAndShowPicker
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Where do you want to get the picture from?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    popupQuery.tag = ACTIONSHEET_TYPE_CHOOSE_ORIGIN;

    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

-(IBAction)choosePhotoButtonPressed:(UIButton *)sender
{
    // Check if the device has a camera
    if(cameraAvailable)
    {
        [self selectSourceTypeAndShowPicker];
    }
    else // no camera
    {
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:_imgPicker animated:YES];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image and populate the image view with it.
    _imageView.image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    _shareButton.enabled = YES;
    
    // Get rid of the picker controller.
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark View stuff

/** Delegate method called when the user selects an option in an action sheet.
 * Two options:
 * actionSheet.tag == ACTIONSHEET_TYPE_CHOOSE_ORIGIN
 * We want to know where the user wants to get the image from.
 * actionSheet.tag == ACTIONSHEET_TYPE_CHOOSE_SHARE
 * We want to know how the user wants to share the image. */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Determine if the photo should be fetched from the camera or
    // the photo library. Is only called if the device has a camera.
    if (actionSheet.tag == ACTIONSHEET_TYPE_CHOOSE_ORIGIN)
    {
        switch (buttonIndex)
        {
            case 2: // cancel - do nothing
                return;
            case 0: // camera
                _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 1: // photo library
                _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
        [self presentModalViewController:_imgPicker animated:YES];
    }
    else if (actionSheet.tag == ACTIONSHEET_TYPE_CHOOSE_SHARE)
    {
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
                NSLog(@"Twitter");
                break;
            case 4: // cancel - do nothing
                return;
        }
    }
    else
        NSLog(@"Undefined type of action sheet");
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
    
    // Makes the shared button look greyed out when disabled
    [_shareButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _shareButton.enabled = NO;
    
    // Set the imageSource to keep track of if we should
    // try to get pictures from the camera as well.
    cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    // Set up the image picker
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
