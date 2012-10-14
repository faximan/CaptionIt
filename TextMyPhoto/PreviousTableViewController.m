//
//  PreviousTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PreviousTableViewController.h"
#import "IOHandler.h"
#import "PreviousTableViewCell.h"
#import "UIImage+Tint.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_CELL_HEIGHT 150

@interface PreviousTableViewController ()
@property NSArray* images;
@end

@implementation PreviousTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    _images = [IOHandler readImages];
    [self.tableView reloadData];
    
    // Do not stick around if no prev projects could be found
    if ([_images count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No previous projects"
                              message:@"No previous projects were found"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [_delegate didCancelPreviousTableViewController:self];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PreviousTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.cellImage.image = [[_images objectAtIndex:indexPath.row] originalImage];
    
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
    StampedImage *si = _images[indexPath.row];
    return MIN(MAX_CELL_HEIGHT, si.originalImage.size.height);
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
        // Remove the right item from the data source
        NSMutableArray *temp = [_images mutableCopy];
        [temp removeObjectAtIndex:indexPath.row];
        _images = (NSArray *)temp;
        
        // Remove the item from the backing storage
        [IOHandler deleteImageAtIndex:indexPath.row];
        
        // Remove tablerow and animate deletion
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate PreviousTableViewController:self didFinishWithImage:(StampedImage*)_images[indexPath.row] forRow:indexPath.row];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_delegate didCancelPreviousTableViewController:self];
}

@end
