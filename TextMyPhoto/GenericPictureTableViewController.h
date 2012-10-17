//
//  GenericPictureTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

static const CGFloat MAX_CELL_HEIGHT = 150.0f;

@protocol GenericPictureTableViewControllerDelegate;

@interface GenericPictureTableViewController : CoreDataTableViewController

@property (nonatomic, weak) id<GenericPictureTableViewControllerDelegate> delegate;

// Returns the height of a cell in the table view
+(CGFloat)cellHeight;
+(CGFloat)cellWidth;

// Takes an UIImage and scales it down and crops it to fill
// a cell in the table vew
+(UIImage *)modifyImageToFillCell:(UIImage *)image;

// Creates a centered attributed string object for given string, font and color
+(NSAttributedString *)makeAttributedStringForString:(NSString *)string andFont:(NSString *)font andColor:(UIColor *)color;

-(IBAction)cancelButtonPressed:(id)sender;

@end

@protocol GenericPictureTableViewControllerDelegate <NSObject>

- (void)didCancelGenericPictureTableViewController:(GenericPictureTableViewController *)genericTableViewController;

@end