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

@protocol PreviousTableViewControllerDelegate;

@interface PreviousTableViewController : CoreDataTableViewController

@property (nonatomic, weak) id<PreviousTableViewControllerDelegate> delegate;

// The database of previous projects
@property (nonatomic, strong) UIManagedDocument *previousDatabase;

@end

@protocol PreviousTableViewControllerDelegate <NSObject>
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithImage:(StampedImage *)image forRow:(NSInteger)index;

- (void)didCancelPreviousTableViewController:(PreviousTableViewController *)previousTableViewController;

@end