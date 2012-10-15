//
//  PreviousTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PreviousTableViewController.h"
#import "PreviousTableViewCell.h"
#import "UIImage+Tint.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_CELL_HEIGHT 150

@implementation PreviousTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate didCancelPreviousTableViewController:self];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PreviousTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.cellImage.image = [stampedImage getOriginalImage];
    
    // Set tint when pressed
    cell.cellImage.highlightedImage = [cell.cellImage.image tintedImageUsingColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3]];
    
    // Add drop shadow
    cell.layer.shadowOffset = CGSizeMake(1, 0);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius = 5;
    cell.layer.shadowOpacity = .75;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return MIN(MAX_CELL_HEIGHT, [stampedImage getOriginalImage].size.height);
}

// Let the user only delete users by pressing "edit". No swiping.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editing ;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {        
        // Remove object from database
        [self.previousDatabase.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - Table view 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.delegate PreviousTableViewController:self didFinishWithImage:stampedImage forRow:indexPath.row];
}

#pragma mark-
#pragma mark Database handling
// attaches an NSFetchRequest to this UITableViewController
- (void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"StampedImage"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateModified" ascending:NO]];
    // no predicate because we want ALL the stamped images
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request                                                                        managedObjectContext:self.previousDatabase.managedObjectContext                                                                          sectionNameKeyPath:nil                                                                                   cacheName:nil];
}

- (void)useDocument
{
    // Check for the status of the database
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.previousDatabase.fileURL path]])
    {
        // does not exist on disk, so create it
        [self.previousDatabase saveToURL:self.previousDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
        {
            [self setupFetchedResultsController];
        }];
    }
    else if (self.previousDatabase.documentState == UIDocumentStateClosed)
    {
        // exists on disk, but we need to open it
        [self.previousDatabase openWithCompletionHandler:^(BOOL success)
        {
            [self setupFetchedResultsController];
        }];
    } else if (self.previousDatabase.documentState == UIDocumentStateNormal)
    {
        // already open and ready to use
        [self setupFetchedResultsController];
    }
}

- (void)setPreviousDatabase:(UIManagedDocument *)previousDatabase
{
    if (_previousDatabase != previousDatabase)
    {
        _previousDatabase = previousDatabase;
        [self useDocument]; // setup the fetched controller
    }
}

@end
