//
//  EditViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "EditViewController.h"
#import "PreviousTableViewController.h"
#import "UIImage+Utilities.h"

@interface EditViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textLabel;
@property (nonatomic, weak) IBOutlet UIView *parentView; // The view that contains the picture and all the addons.

@end

@implementation EditViewController
{
    BOOL thumbAlreadyUpToDate;
}

#pragma mark For sharing the image

// Takes the current addons to the image and renders it to a bitmap
- (UIImage *)renderCurrentImage
{
    UIImage *curImage = [self.stampedImage getOriginalImage];
    // Parentview should here have the same frame as the imageview. Cache the old frame, scale it to full photo resolution and render it.
    CGRect oldFrame = self.parentView.frame;
    float scaleFactor = curImage.size.width / self.imageView.frame.size.width;
    self.parentView.frame = CGRectMake(self.parentView.frame.origin.x, self.parentView.frame.origin.y, curImage.size.width, curImage.size.height);
    
    // Get the context
    UIGraphicsBeginImageContextWithOptions(self.parentView.bounds.size, self.parentView.opaque, 0.0);
        
    // Render the image
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Render the text on top of the image
    // Scale to render sharp (cache old frame)
    CGRect oldLabelFrame = self.textLabel.frame;
    CGFloat oldFontSize = self.textLabel.font.pointSize;
    self.textLabel.font = [UIFont systemFontOfSize:self.textLabel.font.pointSize * scaleFactor];
    self.textLabel.frame = CGRectMake(oldLabelFrame.origin.x, oldLabelFrame.origin.y, oldLabelFrame.size.width * scaleFactor, oldLabelFrame.size.height * scaleFactor);
    self.textLabel.center = self.imageView.center;
    
    // Translate the context to where the label is to render it at the correct position
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), self.textLabel.frame.origin.x, self.textLabel.frame.origin.y);
    [self.textLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Convert to UIImage
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.textLabel.font = [UIFont systemFontOfSize:oldFontSize];
    self.textLabel.frame = oldLabelFrame;
    self.parentView.frame = oldFrame;
    self.textLabel.center = self.imageView.center;
   
    return bitmap;
}

-(void)renderAndSetThumb
{
    // Make sure to only render a new thumb if there are unstaged changes
    if (thumbAlreadyUpToDate)
        return;
    
    // Render the image full scale
    UIImage* temp = [self renderCurrentImage];
    CGFloat cellHeight = [PreviousTableViewController cellHeight];
    CGFloat cellWidth = [PreviousTableViewController cellWidth];
    
    // Do not scale image if it is already small
    if (temp.size.height <= cellHeight || temp.size.width <= cellWidth)
        [self.stampedImage setUIImageThumbImage:temp];
    
    // Scale down image to be a good fit for the cell and do not store a bigger image than necessary
    CGFloat heightScale = cellHeight / temp.size.height;
    CGFloat widthScale = cellWidth / temp.size.width;
    
    CGFloat newWidth, newHeight;
    
    if (heightScale * temp.size.width < cellWidth)
    {
        newWidth = cellWidth;
        newHeight = temp.size.height * widthScale;
    }
    else
    {
        newWidth = temp.size.width * heightScale;
        newHeight = cellHeight;
    }

    [self.stampedImage setUIImageThumbImage:[UIImage imageWithImage:temp scaledToSize:CGSizeMake(newWidth, newHeight)]];
    thumbAlreadyUpToDate = YES;
}

-(IBAction)shareButtonPressed:(id)sender
{
    // Remove keyboard if in edit mode
    [self.textLabel resignFirstResponder];
    
    UIImage *renderedImage = [self renderCurrentImage];
    if (!renderedImage) // Error when rendering
    {
        [self showAlertWithTitle:@"Error" andMessage:@"Your image could not be prepared for sharing."];
        return;
    }
    
    // Pull up a list of places to share this photo to.
    NSArray* dataToShare = @[renderedImage];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark For editing the image
- (IBAction)addText
{
    // Set the textlabel to be in edit mode
    [self.textLabel becomeFirstResponder];
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
	if (color && color != self.textLabel.textColor)
    {
		self.textLabel.textColor = color;
        self.stampedImage.color = color;
        thumbAlreadyUpToDate = NO;
	}
}

#pragma mark UITextField delegate

// Called when the UITextField is in edit mode and return key is hit
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    
    if (self.stampedImage.label != self.textLabel.text)
    {
        self.stampedImage.label = self.textLabel.text;
        thumbAlreadyUpToDate = NO;
    }
    
    return YES;
}

#pragma mark View Stuff
// Show a UIAlertView with the passed title and message
// Only one button called "OK" is added to dissmiss the alert.
- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.textLabel.delegate = self;
    
    self.imageView.image = [self.stampedImage getOriginalImage];
    self.textLabel.textColor = self.stampedImage.color;
    self.textLabel.text = self.stampedImage.label;
    thumbAlreadyUpToDate = NO;
}

- (void)alignViews
{
    // Set the imageview frame to be the same size as the image
    [self.parentView setFrame:[UIImage frameForImage:[self.stampedImage getOriginalImage] inViewAspectFit:_parentView.superview]];
    self.parentView.center = self.parentView.superview.center; // center on screen
    self.textLabel.center = self.imageView.center;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self alignViews];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self renderAndSetThumb];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self alignViews];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Reset parent view before auto rotation to shrink it later
    self.parentView.frame = self.parentView.superview.frame;
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

-(void)didReceiveMemoryWarning
{
    [self renderAndSetThumb];
    [self didReceiveMemoryWarning];
}

@end