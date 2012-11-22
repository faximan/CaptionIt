//
//  FilterPickerCollectionViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-11-22.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "FilterPickerCollectionViewController.h"
#import "GenericCollectionViewCell.h"

@implementation FilterPickerCollectionViewController

#pragma mark - Collection view delegate

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.collectionView.userInteractionEnabled = NO;
    
    // Should respond to this when subclassing
    if ([self.delegate respondsToSelector:@selector(filterPickerCollectionViewController:didFinishWithFilter:)])
        [(id)self.delegate filterPickerCollectionViewController:self didFinishWithFilter:indexPath.row];
}

#pragma mark - Collection view data source
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GenericCollectionViewCell *cell = (GenericCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    cell.cellImage.image = [UIImage imageNamed:[self stringForFilter:indexPath.row]];
    
    return cell;
}

-(NSString *)stringForFilter:(filterTypes)filter
{
    if (filter == FILTER_NORMAL)
        return @"FILTER_NORMAL.png";
    if (filter == FILTER_BW)
        return @"FILTER_BW.JPG";
    if (filter == FILTER_SEPIA)
        return @"FILTER_SEPIA.JPG";
    if (filter == FILTER_CONTRAST)
        return @"FILTER_CONTRAST.JPG";
    return @""; // Error
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 4; // number of filters
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
@end
