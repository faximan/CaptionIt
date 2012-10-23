//
//  GenericPictureTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericPictureTableViewController.h"
#import "GenericTableViewCell.h"
#import "StampedImage+Create.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utilities.h"

@interface GenericPictureTableViewController ()

@end

@implementation GenericPictureTableViewController

-(IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate didCancelGenericPictureTableViewController:self];
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
    static NSString *CellIdentifier = @"Generic Cell";
    GenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Add drop shadow
    cell.layer.shadowOffset = CGSizeMake(1, 0);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius = 5;
    cell.layer.shadowOpacity = .75;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    
    // Override and do your own customization
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return [GenericTableViewCell cellHeight];
}

#pragma mark - Table view

// Override to do something else than dissmissing
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didCancelGenericPictureTableViewController:self];
}

@end
