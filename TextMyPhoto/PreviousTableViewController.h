//
//  PreviousTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviousTableViewControllerDelegate;

@interface PreviousTableViewController : UITableViewController

@property (nonatomic, weak) id<PreviousTableViewControllerDelegate> delegate;

@end

@protocol PreviousTableViewControllerDelegate <NSObject>
- (void)PreviousTableViewController:(PreviousTableViewController *)previousTableViewController didFinishWithSelection:(NSUInteger)selection;
- (void)didCancelPreviousTableViewController:(PreviousTableViewController *)previousTableViewController;

@end