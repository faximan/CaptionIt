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
#import "StampedImage+Create.h"

#define BOARDER_WIDTH 3.5f

@interface LaunchMenuViewController ()

@property (nonatomic, weak) IBOutlet UIView *boarderView;
@property (nonatomic, weak) IBOutlet UIButton *pickButton;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) UIImagePickerController *imgPicker;

// The database of previous projects
@property (nonatomic, strong) UIManagedDocument *previousDatabase;

@end

@implementation LaunchMenuViewController
{
    bool cameraAvailable;
    UIImage *pickedImage;
    StampedImage* stampedImage;
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
        self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imgPicker animated:YES completion:nil];
    }
}

-(IBAction)previousButtonPressed:(UIButton *)sender
{
    if (self.previousDatabase.documentState != UIDocumentStateNormal)
    {
        // Error when opening database
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Error when opening project database."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if ([self numProjectsInDatabase] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No previous projects"
                              message:@"There are no previous projects in the database."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        // Go to previous projects browser
        [self performSegueWithIdentifier:@"previous" sender:self];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get the selected image
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if(pickedImage) //A image was actually selected/taken
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
            self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1: // photo library
            self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
    }
    [self presentViewController:self.imgPicker animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"edit"])
    {
        // Make sure the navigation bar is visible in the next view
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        
        EditViewController *vc = [segue destinationViewController];
        // Create a new database entry if we have a new project
        if (!stampedImage)
        {
            StampedImage *newImage = [StampedImage createStampedImageWithImage:pickedImage inManagedObjectContext:self.previousDatabase.managedObjectContext];
            vc.stampedImage = newImage;
        }
        else
            vc.stampedImage = stampedImage;
    }
    if ([[segue identifier] isEqualToString:@"previous"])
    {
        UINavigationController *nc = (UINavigationController *)[segue destinationViewController];
        PreviousTableViewController *vc = nc.viewControllers[0];
        vc.delegate = self;
        stampedImage = nil;
        vc.previousDatabase = self.previousDatabase;
    }
}

-(void)addBorderToWindow
{
    // Create black border in launchview
    [self.pickButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.pickButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [self.prevButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.prevButton.layer setBorderWidth:BOARDER_WIDTH];
    
    [self.boarderView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.boarderView.layer setBorderWidth:BOARDER_WIDTH];
    [self.boarderView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBorderToWindow];
	
    // Make sure we know whether this device has a camera or not
    cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if (!self.imgPicker)
        self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    
    stampedImage = nil;
}

// Hide navigation bar for this view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Create database
    [self loadDatabase];
}

// Because opening of the database is asynchronus
// we do not want the user to start navigating around the app
// when it is not ready to use.
-(void)makeNavigationVisible
{
    _pickButton.hidden = NO;
    _prevButton.hidden = NO;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)didReceiveMemoryWarning
{
    [self saveDatabase];    
    [super didReceiveMemoryWarning];
}

#pragma mark-
#pragma mark Database stuff

// Returns the number of projects stored in the database
-(NSUInteger)numProjectsInDatabase
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StampedImage"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSUInteger numProjects = [self.previousDatabase.managedObjectContext countForFetchRequest:request error:&error];
    return (error) ? 0 : numProjects;
}

-(void)loadDatabase
{
    // Create the database if it is not set
    if (!self.previousDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Previous Projects Database"];
        // url is now "<Documents Directory>/Default Previous Projects Database"
        self.previousDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
}

-(void)saveDatabase
{
    [self.previousDatabase.managedObjectContext save:nil];
}

- (void)setPreviousDatabase:(UIManagedDocument *)previousDatabase
{
    if (_previousDatabase != previousDatabase)
    {
        _previousDatabase = previousDatabase;
        [self useDocument]; // setup the fetched controller
    }
}

- (void)useDocument
{
    // Check for the status of the database
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.previousDatabase.fileURL path]])
    {
        // does not exist on disk, so create it
        [self.previousDatabase saveToURL:self.previousDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             [self makeNavigationVisible];
         }];
    }
    else if (self.previousDatabase.documentState == UIDocumentStateClosed)
    {
        // exists on disk, but we need to open it
        [self.previousDatabase openWithCompletionHandler:^(BOOL success)
         {
             [self makeNavigationVisible];
         }];
    } else if (self.previousDatabase.documentState == UIDocumentStateNormal)
    {
        // already open and ready to use
        [self makeNavigationVisible];
    }
}


#pragma mark -
#pragma mark PreviousTableViewControllerDelegate
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index
{
    stampedImage = image;
    [self performSegueWithIdentifier:@"edit" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didCancelPreviousTableViewController:(PreviousTableViewController *)previousTableViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
