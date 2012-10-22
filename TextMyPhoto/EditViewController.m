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
@property (nonatomic, weak) IBOutlet UIView *parentView; // The view that contains the picture and all the addons.
@property (nonatomic, weak) NSSet* labels;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation EditViewController
{
    BOOL inTextAddMode; // make sure to not add more labels in text add mode
    UITextView *activeField;
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
    self.parentView.frame = oldFrame;
    
    // Render the text on top of the image
    for (UIView *view in self.parentView.subviews)
    {
        if ([view isKindOfClass:[UITextView class]])
        {
            UITextView *curLabel = (UITextView *)view;
           
            CGRect oldLabelFrame = curLabel.frame;
            UIFont *oldFont = curLabel.font;
            curLabel.font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize * scaleFactor];
            
            CGRect newLabelFrame = oldLabelFrame;
            newLabelFrame.size.height *= scaleFactor;
            newLabelFrame.size.width *= scaleFactor;
            newLabelFrame.origin.x *= scaleFactor;
            newLabelFrame.origin.y *= scaleFactor;
            curLabel.frame = newLabelFrame;
            
            // Move to new position and render
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), newLabelFrame.origin.x, newLabelFrame.origin.y);
            [curLabel.layer renderInContext:UIGraphicsGetCurrentContext()];
            CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -newLabelFrame.origin.x, -newLabelFrame.origin.y);
            
            // Put back
            curLabel.frame = oldLabelFrame;
            curLabel.font = oldFont;
        }
    }
    
    // Convert to UIImage
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    return bitmap;
}

-(IBAction)shareButtonPressed:(id)sender
{
    // Remove keyboard if in edit mode
    [self resignFirstResponder];
    
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
- (IBAction)addLabel:(UILongPressGestureRecognizer *)sender
{
    // Do not add another label if one is already being edited
    if (!inTextAddMode)
    {
        // Get tap location
        CGPoint location = [sender locationInView:self.parentView];
        
        CustomLabel *newLabel = [[CustomLabel alloc] initWithStampedImage:self.stampedImage
                                                                withFrame:CGRectMake(location.x, location.y ,CUSTOM_LABEL_DEFAULT_FRAME_WIDTH, CUSTOM_LABEL_DEFAULT_FRAME_HEIGHT)
                                                                  andText:@""
                                                                  andSize:CUSTOM_LABEL_DEFAULT_FONT_SIZE];
        newLabel.delegate = self;
        
        // Update database
        newLabel.tag = [self.stampedImage.labels count]; // id
        
        [self.parentView addSubview:newLabel];
        [newLabel becomeFirstResponder];
    }
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
	if (color && color != self.stampedImage.color)
    {
        self.stampedImage.color = color;
        
        // Change font for all labels
        for (UIView *view in self.parentView.subviews)
            if ([view isKindOfClass:[UITextView class]])
            {
                ((UITextView *)view).textColor = color;
                [view setNeedsDisplay];
            }
    }
}

#pragma mark UITextView delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
    inTextAddMode = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    inTextAddMode = NO;
    
    [self.stampedImage updateLabel:textView];
    
    // remove empty labels
    if ([textView.text isEqualToString:@""])
        [textView removeFromSuperview];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Remove keyboard on carrige return
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    // Calculate new textsize
    NSString *newString = [NSString stringWithFormat:@"%@%@%@", [textView.text substringToIndex:range.location], text, [textView.text substringFromIndex:range.location + range.length]];
    
    CGRect frame = textView.frame;   
    frame.size = [newString sizeWithFont:textView.font];
    frame.size.width += CUSTOM_LABEL_PADDING;
    frame.size.height += CUSTOM_LABEL_PADDING;
    textView.frame = frame;
    return YES;
}

-(void)customLabeldidChangeSizeOrPosition:(CustomLabel *)customLabel
{
    [self.stampedImage updateLabel:customLabel];
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
    
    self.imageView.image = [self.stampedImage getOriginalImage];
    
    // Add all labels
    for (Label *label in self.stampedImage.labels)
    {
        CustomLabel *newLabel = [[CustomLabel alloc] initWithStampedImage:self.stampedImage
                                                                withFrame:CGRectMake([label.x floatValue], [label.y floatValue], [label.width floatValue], [label.height floatValue])
                                                                  andText:label.text
                                                                  andSize:[label.fontSize floatValue]];
        newLabel.delegate = self;
        [self.parentView addSubview:newLabel];
    }
    
    // Generate thumb if there is none since before
    if (!self.stampedImage.thumbImage)
        [self.stampedImage setUIImageThumbImage:[PreviousTableViewController modifyImageToFillCell:self.imageView.image]];
}

- (void)alignViews
{
    // Set the imageview frame to be the same size as the image
    [self.parentView setFrame:[UIImage frameForImage:[self.stampedImage getOriginalImage] inViewAspectFit:_parentView.superview]];
    self.parentView.center = self.parentView.superview.center; // center on screen
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self alignViews];
    
    [self registerForKeyboardNotifications];
    
    inTextAddMode = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pick font"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        FontPickerTableViewController *fontPicker = nc.viewControllers[0];
        fontPicker.delegate = self;
        
        // Set the properties for rending the font nicely
        fontPicker.curImage = [FontPickerTableViewController modifyImageToFillCell:[self.stampedImage getOriginalImage]];
        fontPicker.curColor = self.stampedImage.color;
    }
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGPoint convertedPointToView = [activeField.superview convertPoint:activeField.frame.origin toView:self.view];
    convertedPointToView.y += activeField.frame.size.height;

    if (!CGRectContainsPoint(aRect, convertedPointToView))
    {
        CGPoint scrollPoint = CGPointMake(0.0, convertedPointToView.y -kbSize.height + (self.view.frame.size.height - self.scrollView.frame.size.height));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}


#pragma mark -
#pragma mark FontPickerTableViewControllerDelegate

-(void)fontPickerTableViewController:(FontPickerTableViewController *)fontPickerTableViewControllerfontPickerTableViewController didFinishWithFont:(NSString *)font
{
    self.stampedImage.font = font;
    
    // Change font for all labels
    for (UIView *view in self.parentView.subviews)
        if ([view isKindOfClass:[UITextView class]])
        {
            ((UITextView *)view).font = [UIFont fontWithName:font size:((UITextView *)view).font.pointSize];
            [view setNeedsDisplay];
        }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didCancelGenericPictureTableViewController:(GenericPictureTableViewController *)genericTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
