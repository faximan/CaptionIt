//
//  EditViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "EditViewController.h"
#import "PreviousCollectionViewController.h"
#import "StylePickerCollectionViewController.h"
#import "UIImage+Utilities.h"
#import "ImageFilter.h"
#import "LoadingView.h"
#import "Appirater.h"

@interface EditViewController ()

@property (nonatomic, weak) IBOutlet InverseableView *labelContainerView; // The view that contains the picture and all the addons.
@property (nonatomic, weak) IBOutlet UIImageView *originalImage;
@property (nonatomic, weak) NSSet* labels;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic, weak) IBOutlet LoadingView *loadingView;
@property (nonatomic, weak) IBOutlet UIImageView *tapToAddLabelNotificationImage;

@end

@implementation EditViewController
{
    BOOL inTextAddMode; // make sure to not add more labels in text add mode
    UITextView *activeField;
    
    BOOL needsNewThumbRendering; // only save the project when settings have been made to the stamped image object
}
#pragma mark Properties
-(void)setImageToStamp:(UIImage *)imageToStamp
{
    if (imageToStamp != _imageToStamp)
    {
        _imageToStamp = imageToStamp;
        
        // The preview image is no longer valid
        self.colorPreviewImage = nil;
    }
}

#pragma mark -
#pragma mark For sharing the image

// Takes the current addons to the image and renders it to a bitmap
- (UIImage *)renderCurrentImage
{
    self.loadingView.hidden = NO;
    NSAssert(self.imageToStamp, nil);
    
    float scaleFactor = self.imageToStamp.size.width / self.labelContainerView.frame.size.width;
    
    // labelContainerView should here have the same frame as the imageview. Cache the old frame, scale it to full photo resolution and render it.
    CGRect oldLabelViewFrame = self.labelContainerView.frame;
    CGRect oldImageViewFrame = self.originalImage.frame;
    CGRect tempLabelFrame = oldLabelViewFrame;
    CGRect tempImageFrame = oldImageViewFrame;
    tempLabelFrame.size = self.imageToStamp.size;
    tempImageFrame.size = self.imageToStamp.size;
    self.labelContainerView.frame = tempLabelFrame;
    self.originalImage.frame = tempImageFrame;
    
    // Render the text on top of the image
    // Resize labels to the correct size
    for (UITextView *curLabel in self.labelContainerView.subviews)
    {
        curLabel.font = [UIFont fontWithName:curLabel.font.fontName size:curLabel.font.pointSize * scaleFactor];
        
        // Make sure to put the label in the right place
        curLabel.frame = CGRectMake(curLabel.frame.origin.x * scaleFactor, curLabel.frame.origin.y * scaleFactor, curLabel.frame.size.width, curLabel.frame.size.height);
    }
    
    // Get the context
    UIGraphicsBeginImageContextWithOptions(self.labelContainerView.bounds.size, YES, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Render the scene
    [self.originalImage.layer renderInContext:context];
    [self.labelContainerView.layer renderInContext:context];
    
    // Convert to UIImage
    UIImage *bitmap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Move back the labels and resize them
    for (UITextView *curLabel in self.labelContainerView.subviews)
    {
        curLabel.font = [UIFont fontWithName:curLabel.font.fontName size:curLabel.font.pointSize / scaleFactor];
        
        // Make sure to put the label in the right place
        curLabel.frame = CGRectMake(curLabel.frame.origin.x / scaleFactor, curLabel.frame.origin.y / scaleFactor, curLabel.frame.size.width, curLabel.frame.size.height);
    }
    
    // Set back the old frame
    self.labelContainerView.frame = oldLabelViewFrame;
    self.originalImage.frame = oldImageViewFrame;
    
    self.loadingView.hidden = YES;
    return bitmap;
}

-(IBAction)shareButtonPressed:(id)sender
{
    NSAssert(self.stampedImage, nil);
    // Remove keyboard if in edit mode
    [self resignFirstResponder];
    
    UIImage *renderedImage = [self renderCurrentImage];
    if (!renderedImage) // Error when rendering
    {
        [self showAlertWithTitle:@"Error" andMessage:@"Your image could not be prepared for sharing."];
    }
    else
    {
        // Pull up a list of places to share this photo to.
        NSArray* dataToShare = @[renderedImage];
        UIActivityViewController* activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                          applicationActivities:nil];
        
        // Set app rater significant when user completes sharing
        [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            [Appirater userDidSignificantEvent:YES];
        }];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    
    [self setThumb];    
}

#pragma mark -
#pragma mark For editing the image
- (IBAction)addLabel:(UILongPressGestureRecognizer *)sender
{
    // Do not add another label if one is already being edited
    if (!inTextAddMode)
    {
        // Get tap location
        CGPoint location = [sender locationInView:self.labelContainerView];
        
        CustomLabel *newLabel = [[CustomLabel alloc] initWithStampedImage:self.stampedImage
                                                                withFrame:CGRectMake(location.x, location.y ,CUSTOM_LABEL_DEFAULT_FRAME_WIDTH, CUSTOM_LABEL_DEFAULT_FRAME_HEIGHT)
                                                                  andText:@""
                                                                  andSize:CUSTOM_LABEL_DEFAULT_FONT_SIZE
                                                                   andTag:[self.stampedImage.labels count]];
        newLabel.delegate = self;
        
        [self.labelContainerView addSubview:newLabel];
        [newLabel becomeFirstResponder];
    }
}

// Pull up the color picker
- (IBAction)changeColor:(id)sender
{
    NSAssert(self.imageToStamp && self.stampedImage, nil);
    
    MNColorPicker *colorPicker = [[MNColorPicker alloc] init];
	colorPicker.delegate = self;
    colorPicker.color = self.stampedImage.color;
    colorPicker.currentFont = self.stampedImage.font;
    
    if (!self.colorPreviewImage)
    {
        CGRect colorPreviewFrame = COLORVIEW_FRAME_PORTRAIT;
        
        UIImage *newPreviewImage = [[UIImage modifyImage:self.imageToStamp toFillRectWithWidth:colorPreviewFrame.size.width andHeight:colorPreviewFrame.size.height] getCenterOfImageWithWidth:colorPreviewFrame.size.width andHeight:colorPreviewFrame.size.height];
        // Shrink preview image and cache it for fast drawing
        self.colorPreviewImage = newPreviewImage;
    }
    colorPicker.currentImage = self.colorPreviewImage;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:colorPicker];
    [self presentViewController:navigationController animated:YES completion:nil];
}

// Inverse the text using a mask
// Inverse text is not in use right now!
/*- (IBAction)inverseText:(id)sender
{
    // Invert text and picture
    needsNewThumbRendering = YES;
    self.labelContainerView.inverseMode = !self.labelContainerView.inverseMode;
    self.stampedImage.inverted = [NSNumber numberWithBool:self.labelContainerView.inverseMode];
}*/

- (IBAction)toggleFade:(id)sender
{
    needsNewThumbRendering = YES;
    self.labelContainerView.shouldFade = !self.labelContainerView.shouldFade;
    self.stampedImage.shouldFade = [NSNumber numberWithBool:self.labelContainerView.shouldFade];
}

#pragma mark -
#pragma mark MNColorPickerDelegate

- (void)colorPicker:(MNColorPicker*)colorPicker didFinishWithColor:(UIColor *)color
{
	if (color && color != self.stampedImage.color)
    {
        needsNewThumbRendering = YES;
        self.stampedImage.color = color;
        [self.labelContainerView setLabelColors];
        [self.labelContainerView setNeedsDisplay];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITextView delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    activeField = textView;
    
    // We should not be able to move around/resize textview when it is being edited
    for (UITextView *tw in self.labelContainerView.subviews)
        tw.userInteractionEnabled = NO;
    
    inTextAddMode = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    inTextAddMode = NO;
    needsNewThumbRendering = YES;
    
    // enable moving and resizing
    for (UITextView *tw in self.labelContainerView.subviews)
        tw.userInteractionEnabled = YES;
    
    [self.stampedImage updateLabel:textView];
    [self.labelContainerView setNeedsDisplay];
    
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
    
    [((CustomLabel *)textView) updateFrameForText:newString];
    
    [self.labelContainerView setNeedsDisplay];
    return YES;
}

-(void)customLabeldidChangeSizeOrPosition:(CustomLabel *)customLabel
{
    [self.stampedImage updateLabel:customLabel];
    needsNewThumbRendering = YES;
    [self.labelContainerView setNeedsDisplay];
}

-(void)customLabelIsChangingSizeOrPosition:(CustomLabel *)customLabel
{
    [self.labelContainerView setNeedsDisplay];
}

#pragma mark -
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
    
    // The stamped image has not been created yet
    self.loadingView.hidden = NO;
    [self setToolbarVisible:NO];
    self.navigationItem.rightBarButtonItem = nil;
    
    [self loadImageToBeCaptioned];
}

-(void)loadImageToBeCaptioned
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if (!self.stampedImage) // A new project is being created
        {
            NSAssert(self.imageToStamp && self.database, nil);
            
            if (!self.imageToStampURL)
            {
                // Save image to camera roll since it is a newly captured image
                self.imageToStampURL = [UIImage saveImageToAssetLibrary:self.imageToStamp];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUpTheImageWhenURLIsSet];});
        }
        else
        {
            if (!self.imageToStamp)
                self.imageToStamp = [UIImage getImageFromAssetURL:[NSURL URLWithString:self.stampedImage.originalImageURL]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.imageToStamp) // image not found in library
                    [self deleteProjectSinceImageWasNotFound];
                else
                    [self setUpTheImageWhenURLIsSet];});
        }
    });
}

-(void)deleteProjectSinceImageWasNotFound
{
    // It is no longer any need to keep this object around
    [self.database.managedObjectContext deleteObject:self.stampedImage];
    [self showAlertWithTitle:@"Error" andMessage:@"This picture does no longer exist in the photo library on your device."];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpTheImageWhenURLIsSet
{
    NSAssert(self.imageToStamp, nil);
    
    if (!self.stampedImage) // create the database entry
    {
        self.stampedImage = [StampedImage createStampedImageWithImageURL:self.imageToStampURL inManagedObjectContext:self.database.managedObjectContext];
    }
    
    // Scale down image if it is too big (on background thread)
    // and set up the view when finished
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        CGFloat widthScale = self.imageToStamp.size.width / MAX_ORIGINAL_IMAGE_WIDTH_FOR_RENDERING;
        CGFloat heightScale = self.imageToStamp.size.height / MAX_ORIGINAL_IMAGE_HEIGHT_FOR_RENDERING;
        if (widthScale > 1.0f || heightScale > 1.0f)
        {
            if (widthScale > heightScale)
            {
                self.imageToStamp = [UIImage imageWithImage:self.imageToStamp scaledToSize:CGSizeMake(MAX_ORIGINAL_IMAGE_WIDTH_FOR_RENDERING, self.imageToStamp.size.height / widthScale)];
            }else{
                self.imageToStamp = [UIImage imageWithImage:self.imageToStamp scaledToSize:CGSizeMake(self.imageToStamp.size.width / heightScale, MAX_ORIGINAL_IMAGE_HEIGHT_FOR_RENDERING)];
            }
        }
        UIImage *filteredImage = [self createFiltredImageWithFilter:self.stampedImage.filterType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.originalImage.image = filteredImage;
            [self setUpViewWithStampedImage];
        });
    });
}

-(void)setUpViewWithStampedImage
{
    NSAssert(self.stampedImage && self.imageToStamp, nil);
    
    // Remove "waiting" UI elements
    self.loadingView.hidden = YES;
    [self setToolbarVisible:YES];
    self.navigationItem.rightBarButtonItem = self.shareButton;
    
    self.labelContainerView.inverseMode = [self.stampedImage.inverted boolValue];
    self.labelContainerView.shouldFade = [self.stampedImage.shouldFade boolValue];
    self.labelContainerView.delegate = self;
    
    // Add all labels
    for (Label *label in self.stampedImage.labels)
    {
        if (![label.text isEqualToString:@""])
        {
            CustomLabel *newLabel = [[CustomLabel alloc] initWithStampedImage:self.stampedImage
                withFrame:CGRectMake([label.x floatValue], [label.y floatValue], [label.width floatValue], [label.height floatValue])
                andText:label.text
                andSize:[label.fontSize floatValue]
                andTag:[label.nbr integerValue]];
            newLabel.delegate = self;
            [self.labelContainerView addSubview:newLabel];
        }
    }
    
    [self alignViews];
    [self.labelContainerView setNeedsDisplay];
    
    // Show helper iff no label has been added
    if (![self.stampedImage.labels count])
        [self showHelperToAddCaption];
    
    // Generate thumb
    needsNewThumbRendering = YES;
    [self setThumb];
}

-(void)showHelperToAddCaption
{
    // Animate fade in and out of helper view
    [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         self.tapToAddLabelNotificationImage.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         // Do some stuff
                         [UIView animateWithDuration:0.5f delay:2.0f options:UIViewAnimationOptionTransitionCrossDissolve
                                          animations:^{
                                              self.tapToAddLabelNotificationImage.alpha = 0.0;
                                          }
                                          completion:nil
                          ];
                     }
     ];
}

- (void)setThumb
{
    NSAssert(self.originalImage, nil);
    
    if (needsNewThumbRendering)
    {
        // Render the image in the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIGraphicsBeginImageContextWithOptions(self.originalImage.frame.size, YES, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [self.originalImage.layer renderInContext:context];
            [self.labelContainerView.layer renderInContext:context];
            UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
            
            CGSize thumbSize = [PreviousCollectionViewController cellImageSizeForImageSize:self.originalImage.frame.size];
            [self.stampedImage setUIImageThumbImage:[UIImage imageWithImage:thumb scaledToSize:thumbSize]];
        });
        needsNewThumbRendering = NO;
    }
}

- (void)alignViews
{
    NSAssert(self.originalImage.image, nil);
    // Set the imageview frame to be the same size as the image
    [self.originalImage setFrame:[UIImage frameForImage:self.originalImage.image inViewAspectFit:self.scrollView]];
    [self.labelContainerView setFrame:self.originalImage.frame];
    self.originalImage.center = self.scrollView.center;
    self.labelContainerView.center = self.scrollView.center; // center on screen
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    inTextAddMode = NO;
    self.tapToAddLabelNotificationImage.alpha = 0.0f; // hidden by default
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self resignFirstResponder];
    [self setThumb];
}

- (void)setToolbarVisible:(BOOL)show
{
    if (show == YES && self.toolbar.hidden == YES)
    {        
        // Move the frame out of sight
        CGRect frame = self.toolbar.frame;
        
        // Put the toolbar below the main view
        frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height;
        self.toolbar.frame = frame;
        
        // Display it nicely
        self.toolbar.hidden = NO;
        frame.origin.y -= frame.size.height;
        [self.view bringSubviewToFront:self.toolbar];
        
        [UIView animateWithDuration:0.3f
                         animations:^(void) {
                             self.toolbar.frame = frame;
                         }
         ];
    }
    else if (show == NO && self.toolbar.hidden == NO)
    {
        self.toolbar.hidden = YES;
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Reset labelContainerView before auto rotation to shrink it later
    self.labelContainerView.frame = self.labelContainerView.superview.frame;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Shrink labelContainerView to fit image
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
        NSAssert(self.imageToStamp, nil);
        
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        StylePickerCollectionViewController *stylePicker = nc.viewControllers[0];
        stylePicker.delegate = self;
        
        // Set the properties for rending the font nicely
        stylePicker.curImage = [[UIImage modifyImage:self.imageToStamp toFillRectWithWidth:STYLE_PICKER_CELL_IMAGE_WIDTH andHeight:STYLE_PICKER_CELL_IMAGE_HEIGHT] getCenterOfImageWithWidth:STYLE_PICKER_CELL_IMAGE_WIDTH andHeight:STYLE_PICKER_CELL_IMAGE_HEIGHT];;
        stylePicker.curColor = self.stampedImage.color;
    }
    else if ([[segue identifier] isEqualToString:@"pick filter"])
    {
        NSAssert(self.imageToStamp, nil);
        
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        FilterPickerCollectionViewController *filterPicker = nc.viewControllers[0];
        filterPicker.delegate = self;
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
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    CGPoint currentPoint = activeField.frame.origin;
    NSString *heightCheckString = @"W";
    currentPoint.y += [heightCheckString sizeWithFont:[UIFont fontWithName:self.stampedImage.font size:CUSTOM_LABEL_DEFAULT_FONT_SIZE]].height;
    
    CGPoint convertedPointToView = [activeField.superview convertPoint:currentPoint toView:self.view];
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
#pragma mark FilterPickerCollectionViewControllerDelegate
- (void)filterPickerCollectionViewController:(FilterPickerCollectionViewController *)filterPickerCollectionViewController didFinishWithFilter:(filterTypes)filter
{
    // Only do something if a new filter was applied
    if (filter != [self.stampedImage.filterType integerValue])
    {
        // Apply filter in new thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *filteredImage = [self createFiltredImageWithFilter:[NSNumber numberWithInteger:filter]];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.originalImage.image = filteredImage;
                [self.originalImage setNeedsDisplay];
                needsNewThumbRendering = YES;
                self.stampedImage.filterType = @(filter);
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        });
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)createFiltredImageWithFilter:(NSNumber *)filter
{
    NSAssert(self.imageToStamp, nil);
    UIImage *filterImage = nil;
    
    switch ([filter integerValue])
    {
        case FILTER_NORMAL:
            filterImage = self.imageToStamp; // reset
            break;
        case FILTER_BW:
            filterImage = [self.imageToStamp greyscale];
            break;
        case FILTER_SEPIA:
            filterImage = [self.imageToStamp sepia];
            break;
        case FILTER_CONTRAST:
            filterImage = [self.imageToStamp contrast:1.7];
            break;
        default:
            NSLog(@"Invalid filter picked");
    }
    return filterImage;
}

#pragma mark -
#pragma mark StylePickerCollectionViewControllerDelegate

-(void)stylePickerCollectionViewController:(StylePickerCollectionViewController *)stylePickerCollectionViewController didFinishWithFont:(NSString *)font
{
    if (font != self.stampedImage.font)
    {
        needsNewThumbRendering = YES;
        self.stampedImage.font = font;
        [self.labelContainerView setLabelFonts];
        [self.labelContainerView setNeedsDisplay];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark GenericCollectionViewControllerDelegate

-(void)didCancelGenericCollectionViewController:(GenericCollectionViewController *)genericCollectionViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark InverseableViewDeleate
-(UIColor *)colorForStampedImage
{
    return self.stampedImage.color;
}

-(NSString *)fontForStampedImage
{
    return self.stampedImage.font;
}

@end
