//
//  EditViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "EditViewController.h"
#import "UIImage+Utilities.h"
#import "UIImage+Utilities.h"
#import "GenericTableViewCell.h"

@interface EditViewController ()

@property (nonatomic, weak) IBOutlet InverseableView *parentView; // The view that contains the picture and all the addons.
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
    // FIXME: How heavy is this?
- (UIImage *)renderCurrentImage
{
    UIImage *curImage = self.parentView.image;
    float scaleFactor = curImage.size.width / self.parentView.frame.size.width;
    
    // Parentview should here have the same frame as the imageview. Cache the old frame, scale it to full photo resolution and render it.
    CGRect oldFrame = self.parentView.frame;
    CGRect tempFrame = oldFrame;
    tempFrame.size = curImage.size;
    self.parentView.frame = tempFrame;
    
    // Render the text on top of the image
    // Resize labels to the correct size
    for (UITextView *curLabel in self.parentView.subviews)
    {
        curLabel.font = [UIFont fontWithName:curLabel.font.fontName size:curLabel.font.pointSize * scaleFactor];
        
        CGRect newLabelFrame = curLabel.frame;
        newLabelFrame.size.height *= scaleFactor;
        newLabelFrame.size.width *= scaleFactor;
        newLabelFrame.origin.x *= scaleFactor;
        newLabelFrame.origin.y *= scaleFactor;
        curLabel.frame = newLabelFrame;
    }
    
    // Get the context
    UIGraphicsBeginImageContextWithOptions(self.parentView.bounds.size, self.parentView.opaque, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Render the scene
    [self.parentView.layer renderInContext:context];
    
    // Move back the labels and resize them
    for (UITextView *curLabel in self.parentView.subviews)
    {
        curLabel.font = [UIFont fontWithName:curLabel.font.fontName size:curLabel.font.pointSize / scaleFactor];
        
        CGRect newLabelFrame = curLabel.frame;
        newLabelFrame.size.height /= scaleFactor;
        newLabelFrame.size.width /= scaleFactor;
        newLabelFrame.origin.x /= scaleFactor;
        newLabelFrame.origin.y /= scaleFactor;
        curLabel.frame = newLabelFrame;
    }
    
    // Set back the old frame
    self.parentView.frame = oldFrame;
    
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
                                                                  andSize:CUSTOM_LABEL_DEFAULT_FONT_SIZE
                                                                   andTag:[self.stampedImage.labels count]];
        
        // Remove useless padding.
        newLabel.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
        newLabel.delegate = self;
        
        [self.parentView addSubview:newLabel];
        [newLabel becomeFirstResponder];
    }
}

// Pull up the color picker
- (IBAction)changeColor:(id)sender
{
    MNColorPicker *colorPicker = [[MNColorPicker alloc] init];
	colorPicker.delegate = self;
    colorPicker.color = self.stampedImage.color;
    colorPicker.stampedImage = self.stampedImage;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self presentViewController:navigationController animated:YES completion:nil];
}

// Inverse the text using a mask
- (IBAction)inverseText:(id)sender
{
    // Invert text and picture
    self.parentView.inverseMode = !self.parentView.inverseMode;
    self.stampedImage.inverted = [NSNumber numberWithBool:self.parentView.inverseMode];
}

#pragma mark MNColorPickerDelegate

- (void)colorPicker:(MNColorPicker*)colorPicker didFinishWithColor:(UIColor *)color
{
	if (color && color != self.stampedImage.color)
    {
        self.stampedImage.color = color;
        [self.parentView setNeedsDisplay];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITextView delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
    
    // We should not be able to move around/resize textview when it is being edited
    textView.userInteractionEnabled = NO;
    inTextAddMode = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    inTextAddMode = NO;
    
    // enable moving and resizing
    textView.userInteractionEnabled = YES;
    
    [self.stampedImage updateLabel:textView];
    [self.parentView setNeedsDisplay];
    
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
    
    [self.parentView setNeedsDisplay];
    return YES;
}

-(void)customLabeldidChangeSizeOrPosition:(CustomLabel *)customLabel
{
    [self.stampedImage updateLabel:customLabel];
    [self.parentView setNeedsDisplay];
}

-(void)customLabelIsChangingSizeOrPosition:(CustomLabel *)customLabel
{
    [self.parentView setNeedsDisplay];
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
    
    self.parentView.image = [self.stampedImage getOriginalImage];
    self.parentView.inverseMode = [self.stampedImage.inverted boolValue];
    self.parentView.delegate = self;
    
    // Add all labels
    for (Label *label in self.stampedImage.labels)
    {
        CustomLabel *newLabel = [[CustomLabel alloc] initWithStampedImage:self.stampedImage
                                                                withFrame:CGRectMake([label.x floatValue], [label.y floatValue], [label.width floatValue], [label.height floatValue])
                                                                  andText:label.text
                                                                  andSize:[label.fontSize floatValue]
                                                                   andTag:[label.nbr integerValue]];
        newLabel.delegate = self;
        
        // Only add labels that contain text
        if (![newLabel.text isEqualToString:@""])
            [self.parentView addSubview:newLabel];
    }
    
    [self.parentView setNeedsDisplay];
    
    // Generate thumb if there is none since before
    if (!self.stampedImage.thumbImage)
        [self.stampedImage setUIImageThumbImage:[UIImage modifyImage:self.parentView.image toFillRectWithWidth:[GenericTableViewCell cellWidth] andHeight:[GenericTableViewCell cellHeight]]];
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
    
    [self resignFirstResponder];
    
    // Update thumbImage of current stamped image
    UIImage *newThumb = [self renderCurrentImage];
    [self.stampedImage setUIImageThumbImage:[UIImage modifyImage:newThumb toFillRectWithWidth:[GenericTableViewCell cellWidth] andHeight:[GenericTableViewCell cellHeight]]];
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
        fontPicker.curImage = [UIImage modifyImage:[self.stampedImage getOriginalImage] toFillRectWithWidth:[GenericTableViewCell cellWidth] andHeight:[GenericTableViewCell cellHeight]];
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
    
    [self.parentView setNeedsDisplay];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didCancelGenericPictureTableViewController:(GenericPictureTableViewController *)genericTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark InverseableViewDeleate
-(UIColor *)colorForStampedImage
{
    return self.stampedImage.color;
}

@end
