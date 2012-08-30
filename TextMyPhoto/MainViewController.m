//
//  MainViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize imageView = _imageView;
@synthesize shareButton = _shareButton;
@synthesize imgPicker = _imgPicker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Makes the shared button look greyed out when disabled
    [_shareButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _shareButton.enabled = NO;

    _imgPicker = [[UIImagePickerController alloc] init];
    _imgPicker.delegate = self;
    _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

-(IBAction)shareButtonPressed:(UIButton *)sender
{
    NSLog(@"Share button pressed.");
}

-(IBAction)choosePhotoButtonPressed:(UIButton *)sender
{
    [self presentModalViewController:_imgPicker animated:YES];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image and populate the image view with it.
    _imageView.image = (UIImage *)[info valueForKey:UIImagePickerControllerOriginalImage];
    _shareButton.enabled = YES;
    
    // Get rid of the picker controller.
    [self dismissModalViewControllerAnimated:YES];
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
