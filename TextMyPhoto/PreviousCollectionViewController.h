//
//  PreviousCollectionViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericCollectionViewController.h"
#import "StampedImage+Create.h"

@protocol PreviousCollectionViewControllerDelegate;

@interface PreviousCollectionViewController : GenericCollectionViewController

// The database of previous projects
@property (nonatomic, strong) UIManagedDocument *previousDatabase;

-(IBAction)editButtonPressed:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;

+(CGSize)cellImageSizeForImage:(UIImage *)image;

@end

@protocol PreviousCollectionViewControllerDelegate <GenericCollectionViewControllerDelegate>
- (void)PreviousCollectionViewController:(PreviousCollectionViewController *)previousCollectionViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index;

@end