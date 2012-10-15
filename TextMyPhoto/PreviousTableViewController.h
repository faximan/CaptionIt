//
//  PreviousTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StampedImage+Create.h"
#import "CoreDataTableViewController.h"

#define MAX_CELL_HEIGHT 150.0f

@protocol PreviousTableViewControllerDelegate;

@interface PreviousTableViewController : CoreDataTableViewController

@property (nonatomic, weak) id<PreviousTableViewControllerDelegate> delegate;

// The database of previous projects
@property (nonatomic, strong) UIManagedDocument *previousDatabase;

// Returns the height of a cell in the table view
+(CGFloat)cellHeight;
+(CGFloat)cellWidth;

@end

@protocol PreviousTableViewControllerDelegate <NSObject>
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index;

- (void)didCancelPreviousTableViewController:(PreviousTableViewController *)previousTableViewController;

@end