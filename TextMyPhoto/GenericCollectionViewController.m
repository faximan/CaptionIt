//
//  GenericCollectionViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericCollectionViewController.h"
#import "GenericCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GenericCollectionViewController

-(IBAction)cancelButtonPressed:(id)sender
{
    self.fetchedResultsController.delegate = nil;
    [self.delegate didCancelGenericCollectionViewController:self];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - Collection view data source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Collection view cell";
    GenericCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Add drop shadow
    cell.whiteView.layer.shadowOffset = CGSizeMake(1, 1);
    cell.whiteView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.whiteView.layer.shadowRadius = 3;
    cell.whiteView.layer.shadowOpacity = .75;
    CGRect shadowFrame = cell.whiteView.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.whiteView.layer.shadowPath = shadowPath;
    
    // Override and do your own customization
    return cell;
}

#pragma mark - Collection view delegate

// Override to do something else than dissmissing
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.fetchedResultsController.delegate = nil;
    [self.delegate didCancelGenericCollectionViewController:self];
}

@end
