//
//  EditViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "EditViewController.h"
#import "IOHandler.h"

@implementation EditViewController

#pragma mark For sharing the image

// Returns a CGRect that corresponds to the actual part of the screen containing image when added with Aspect Fit into imageview.
-(CGRect)frameForImage:(UIImage*)image inViewAspectFit:(UIView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    
    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

// Takes the current addons to the image and renders it to a bitmap
- (UIImage *)renderCurrentImage
{
    // Parentview should here have the same frame as the imageview. Cache the old frame, scale it to full photo resolution and render it.
    CGRect oldFrame = _parentView.frame;
    float scaleFactor = _stampedImage.originalImage.size.width / _imageView.frame.size.width;
    _parentView.frame = CGRectMake(_parentView.frame.origin.x, _parentView.frame.origin.y, _stampedImage.originalImage.size.width, _stampedImage.originalImage.size.height);
    
    // Get the context
    UIGraphicsBeginImageContextWithOptions(_parentView.bounds.size, _parentView.opaque, 0.0);
        
    // Render the image
    [_imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Render the text on top of the image
    // Scale to render sharp (cache old frame)
    CGRect oldLabelFrame = _textLabel.frame;
    CGFloat oldFontSize = _textLabel.font.pointSize;
    _textLabel.font = [UIFont systemFontOfSize:_textLabel.font.pointSize * scaleFactor];
    _textLabel.frame = CGRectMake(oldLabelFrame.origin.x, oldLabelFrame.origin.y, oldLabelFrame.size.width * scaleFactor, oldLabelFrame.size.height * scaleFactor);
     _textLabel.center = _imageView.center;
    
    // Translate the context to where the label is to render it at the correct position
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), _textLabel.frame.origin.x, _textLabel.frame.origin.y);
    [_textLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Convert to UIImage
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _textLabel.font = [UIFont systemFontOfSize:oldFontSize];
    _textLabel.frame = oldLabelFrame;
    _parentView.frame = oldFrame;
    _textLabel.center = _imageView.center;
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
    // Remove keyboard if in edit mode
    [_textLabel resignFirstResponder];
    
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

// Pull up the color picker
- (IBAction)changeColor
{
    MNColorPicker *colorPicker = [[MNColorPicker alloc] init];
	colorPicker.delegate = self;
	colorPicker.color = self.view.backgroundColor;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark MNColorPickerDelegate

- (void)colorPicker:(MNColorPicker*)colorPicker didFinishWithColor:(UIColor *)color
{
	[self dismissViewControllerAnimated:YES completion:nil];
	if (color)
    {
		_textLabel.textColor = color;
        _stampedImage.textColor = color;
	}
}

#pragma mark UITextField delegate

// Called when the UITextField is in edit mode and return key is hit
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    _stampedImage.stampedText = _textLabel.text;
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
    self.navigationItem.rightBarButtonItems = @[buttonItem];
    
    _stampedImage = [[StampedImage alloc] init];
    _textLabel.delegate = self;
}

- (void)alignViews
{
    // Set the imageview frame to be the same size as the image
    [_parentView setFrame:[self frameForImage:_stampedImage.originalImage inViewAspectFit:_parentView.superview]];
    _parentView.center = _parentView.superview.center; // center on screen
    _textLabel.center = _imageView.center;
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
    _textLabel.textColor = _stampedImage.textColor;
    _textLabel.text = _stampedImage.stampedText;
    [self alignViews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self alignViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Serialize current work to disk
    [IOHandler saveImage:_stampedImage];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Reset parent view before auto rotation to shrink it later
    _parentView.frame = _parentView.superview.frame;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Shrink parent view to fit image
    [self alignViews];
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
