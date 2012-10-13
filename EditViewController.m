//
//  EditViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "EditViewController.h"
#import "IOHandler.h"

@interface EditViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextField *textLabel;
@property (nonatomic, weak) IBOutlet UIView *parentView; // The view that contains the picture and all the addons.

@end

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

-(void)shareButtonPressed
{
    // Remove keyboard if in edit mode
    [_textLabel resignFirstResponder];
    
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
    [self presentViewController:activityViewController animated:YES completion:^{}];
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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    _stampedImage.stampedText = _textLabel.text;
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
    
    self.title = @"Edit";
    
    // Add share button to navigation bar
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(shareButtonPressed)];
    self.navigationItem.rightBarButtonItems = @[buttonItem];
    
    if (!_stampedImage)
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

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    if (!parent)
    {
        // Back button was pressed. Save current work
        [IOHandler saveImage:_stampedImage forIndex:_projectNbr];
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
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

@end
