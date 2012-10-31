//
//  StylePickerCollectionViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-31.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StylePickerCollectionViewController.h"
#import "GenericCollectionViewCell.h"

@implementation StylePickerCollectionViewController
{
    NSArray *fontArray;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set current fonts
    fontArray = FONT_ARRAY;
    [self.collectionView reloadData];
}

#pragma mark - Collection view data source
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GenericCollectionViewCell *cell = (GenericCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    // Set the image
    cell.cellImage.image = self.curImage;
    cell.label.text = fontArray[indexPath.row];
    cell.label.font = [UIFont fontWithName:fontArray[indexPath.row] size:18.0f];
    cell.label.textColor = self.curColor;
    
    // Set the string to be the font name if no string is set
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [fontArray count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark - Collection view delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Should respond to this when subclassing
    if ([self.delegate respondsToSelector:@selector(stylePickerCollectionViewController:didFinishWithFont:)])
        [(id)self.delegate stylePickerCollectionViewController:self didFinishWithFont:fontArray[indexPath.row]];
}

@end
