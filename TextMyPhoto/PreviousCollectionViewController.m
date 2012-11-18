//
//  PreviousCollectionViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PreviousCollectionViewController.h"
#import "GenericCollectionViewCell.h"

static const CGFloat PREVIOUS_THUMB_WIDTH = 270.0f;
static const CGFloat CELL_WIDTH = 310.0f;


@implementation PreviousCollectionViewController
{
    BOOL inEditMode;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    inEditMode = NO;
    
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

-(IBAction)editButtonPressed:(id)sender
{
    UIBarButtonItem *editButton = (UIBarButtonItem *)sender;
    
    if (!inEditMode)
    {
        editButton.style = UIBarButtonItemStyleDone;
        editButton.title = @"Done";
    }
    else
    {
        editButton.style = UIBarButtonItemStyleBordered;
        editButton.title = @"Edit";
    }
    inEditMode = !inEditMode;
    [self.collectionView reloadData];
}


-(IBAction)deleteButtonPressed:(id)sender
{
    UIButton *deleteButton = (UIButton *)sender;
    
    // Get which project the user wants to delete
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[deleteButton convertPoint:deleteButton.frame.origin toView:self.collectionView]];
    
    // Remove object from database
    [self.previousDatabase.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

+(CGSize)cellImageSizeForImageSize:(CGSize)imageSize
{
    return CGSizeMake(PREVIOUS_THUMB_WIDTH, imageSize.height * (PREVIOUS_THUMB_WIDTH / imageSize.width));
}

#pragma mark - Collection view data source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GenericCollectionViewCell *cell = (GenericCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.cellImage.image = [stampedImage getThumbImage];
    
    // Add remove button if in edit mode
    cell.deleteButton.hidden = !inEditMode;

    return cell;
}

#pragma mark - Collecton view

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Should respond to this when subclassing
    if ([self.delegate respondsToSelector:@selector(PreviousCollectionViewController:didFinishWithImage:forRow:)])
        [(id)self.delegate PreviousCollectionViewController:self didFinishWithImage:stampedImage forRow:indexPath.row];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StampedImage *stampedImage = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImage *image = [stampedImage getThumbImage];
    
    return CGSizeMake(CELL_WIDTH, image.size.height * (CELL_WIDTH / image.size.width));
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
    else
        NSLog(@"document state in useDocument is not normal");
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