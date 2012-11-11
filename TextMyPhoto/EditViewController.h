//
//  EditViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "StampedImage+Create.h"
#import "Label.h"
#import "StylePickerCollectionViewController.h"
#import "MNColorPicker.h"
#import "CustomLabel.h"
#import "InverseableView.h"

@interface EditViewController : UIViewController <CustomLabelDelegate , MNColorPickerDelegate, StylePickerCollectionViewControllerDelegate, InversableViewDelegate>

@property (nonatomic, strong) StampedImage *stampedImage;
@property (nonatomic, strong) UIManagedDocument* database;
@property (nonatomic, strong) UIImage *imageToStamp;
@property (nonatomic, strong) NSURL *imageToStampURL;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView* spinner;

@end
