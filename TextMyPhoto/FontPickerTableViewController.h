//
//  FontPickerTableViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericPictureTableViewController.h"

// All the used font names for the app
#define FONT_ARRAY @[@"HelveticaNeue", @"Didot", @"Cochin-BoldItalic", @"Baskerville", @"AmericanTypewriter", @"Verdana", @"Copperplate"]

@protocol FontPickerTableViewControllerDelegate;

@interface FontPickerTableViewController : GenericPictureTableViewController

@property (nonatomic, strong) UIImage *curImage;
@property (nonatomic, strong) UIColor *curColor;
@property (nonatomic, strong) NSString *curString;

@end

@protocol FontPickerTableViewControllerDelegate <GenericPictureTableViewControllerDelegate>

- (void)genericPictureTableViewController:(GenericPictureTableViewController *)genericTableViewController didFinishWithFont:(NSString *)font;

@end
