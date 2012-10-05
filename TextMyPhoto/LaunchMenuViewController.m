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

@implementation LaunchMenuViewController
{
    bool cameraAvailable;
    UIImage *image;
}

@synthesize boarderView = _boarderView;
@synthesize pickButton = _pickButton;
@synthesize prevButton = _prevButton;
@synthesize imgPicker = _imgPicker;

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
        [self presentModalViewController:_imgPicker animated:YES];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image and populate the image view with it.
    image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    
    if(image) //A image was actually selected/taken
        [self performSegueWithIdentifier:@"edit" sender:nil];
    
    // Get rid of the picker controller.
    [self dismissModalViewControllerAnimated:YES];
}

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
    [self presentModalViewController:_imgPicker animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"edit"])
    {
        EditViewController *vc = [segue destinationViewController];
        if (vc.view)
            vc.imageView.image = image;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Create black border in launchview
    [_pickButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_pickButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [_prevButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_prevButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [_boarderView.layer setBorderColor:[UIColor blackColor].CGColor];
    [_boarderView.layer setBorderWidth:BOARDER_WIDTH];
    [_boarderView setBackgroundColor:[UIColor clearColor]];
    
    // Set color of navigation bar
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    
    // Set the imageSource to keep track of if we should
    // try to get pictures from the camera as well.
    cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    // Set up the image picker
    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
}

// Hide/show navigation bar
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
