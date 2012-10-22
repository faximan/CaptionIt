//
//  PreviousTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PreviousTableViewController.h"
#import "GenericTableViewCell.h"

@implementation PreviousTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (GenericTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GenericTableViewCell *cell = (GenericTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.cellImage.image = [stampedImage getThumbImage];
    return cell;
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
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Should respond to this when subclassing
    if ([self.delegate respondsToSelector:@selector(PreviousTableViewController:didFinishWithImage:forRow:)])
        [(id)self.delegate PreviousTableViewController:self didFinishWithImage:stampedImage forRow:indexPath.row];
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
