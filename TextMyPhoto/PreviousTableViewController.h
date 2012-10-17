//
//  PreviousTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StampedImage+Create.h"
#import "GenericPictureTableViewController.h"

@protocol PreviousTableViewControllerDelegate;

@interface PreviousTableViewController : GenericPictureTableViewController

// The database of previous projects
@property (nonatomic, strong) UIManagedDocument *previousDatabase;

@end

@protocol PreviousTableViewControllerDelegate <GenericPictureTableViewControllerDelegate>
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index;

@end