//
//  GenericPictureTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@protocol GenericPictureTableViewControllerDelegate;

@interface GenericPictureTableViewController : CoreDataTableViewController

@property (nonatomic, weak) id<GenericPictureTableViewControllerDelegate> delegate;

-(IBAction)cancelButtonPressed:(id)sender;

@end

@protocol GenericPictureTableViewControllerDelegate <NSObject>

- (void)didCancelGenericPictureTableViewController:(GenericPictureTableViewController *)genericTableViewController;

@end