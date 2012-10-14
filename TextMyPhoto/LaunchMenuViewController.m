//
//  LaunchMenuViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "LaunchMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EditViewController.h"
#import "StampedImage.h"
#import "IOHandler.h"

#define BOARDER_WIDTH 3.5f

@interface LaunchMenuViewController ()

@property (nonatomic, weak) IBOutlet UIView *boarderView;
@property (nonatomic, weak) IBOutlet UIButton *pickButton;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) UIImagePickerController *imgPicker;

@end

@implementation LaunchMenuViewController
{
    bool cameraAvailable;
    StampedImage *stampedImage;
    NSInteger projectNbr;
}

#pragma mark -
#pragma mark For selecting the image
// The device has a camera, return if it should be used for
// getting the image or if it should be picked from the photo library.
-(void)selectSourceTypeAndShowPicker
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Where do you want to get the picture from?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

-(IBAction)stampPhotoButtonPressed:(UIButton *)sender
{
    // Check if the device has a camera
    if(cameraAvailable)
    {
        [self selectSourceTypeAndShowPicker];
    }
    else // no camera
    {
        _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imgPicker animated:YES completion:nil];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image and populate the image view with it.
    stampedImage.originalImage = info[UIImagePickerControllerOriginalImage];
    stampedImage.urlToOriginalImage = info[UIImagePickerControllerReferenceURL];
    
    projectNbr = NSIntegerMax;
    if(stampedImage.originalImage) //A image was actually selected/taken
        [self performSegueWithIdentifier:@"edit" sender:nil];
    
    // Get rid of the picker controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark View Stuff

/** Delegate method called when the user selects an option in an action sheet. */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Determine if the photo should be fetched from the camera or
    // the photo library. Is only called if the device has a camera.
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
    [self presentViewController:_imgPicker animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"edit"])
    {
        // Make sure the navigation bar is visible in the next view
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        EditViewController *vc = [segue destinationViewController];
        if (vc.view)
        {
            vc.stampedImage = stampedImage;
            vc.projectNbr = projectNbr;
        }
    }
    if ([[segue identifier] isEqualToString:@"previous"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        PreviousTableViewController *vc = nc.viewControllers[0];
        vc.delegate = self;
    }
}

-(void)addBorderToWindow
{
    // Create black border in launchview
    [_pickButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_pickButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [_prevButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_prevButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [_boarderView.layer setBorderColor:[UIColor blackColor].CGColor];
    [_boarderView.layer setBorderWidth:BOARDER_WIDTH];
    [_boarderView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBorderToWindow];
	
    // Make sure we know whether this device has a camera or not
    cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (!_imgPicker)
        _imgPicker = [[UIImagePickerController alloc] init];
    if (!stampedImage)
        stampedImage = [[StampedImage alloc] init];
    _imgPicker.delegate = self;
}

// Hide navigation bar for this view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark PreviousTableViewControllerDelegate
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index
{
    stampedImage = image;
    projectNbr = index;
    [self performSegueWithIdentifier:@"edit" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelPreviousTableViewController:(PreviousTableViewController *)previousTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
