//
//  StylePickerCollectionViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-31.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericCollectionViewController.h"

// All the used font names for the app
#define FONT_ARRAY @[@"HelveticaNeue", @"Didot", @"Cochin-BoldItalic", @"Baskerville", @"AmericanTypewriter", @"Verdana", @"Copperplate"]

static const CGFloat STYLE_PICKER_CELL_IMAGE_WIDTH = 135.0f;
static const CGFloat STYLE_PICKER_CELL_IMAGE_HEIGHT = 135.0f;

@protocol StylePickerCollectionViewControllerDelegate;

@interface StylePickerCollectionViewController : GenericCollectionViewController

@property (nonatomic, strong) UIImage *curImage;
@property (nonatomic, strong) UIColor *curColor;

@end

@protocol StylePickerCollectionViewControllerDelegate <GenericCollectionViewControllerDelegate>

- (void)stylePickerCollectionViewController:(StylePickerCollectionViewController *)stylePickerCollectionViewController didFinishWithFont:(NSString *)font;

@end
