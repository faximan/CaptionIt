//
//  LaunchMenuViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOARDER_WIDTH 3.5f

@interface LaunchMenuViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIView *boarderView;
@property (nonatomic, weak) IBOutlet UIButton *pickButton;
@property (nonatomic, weak) IBOutlet UIButton *prevButton;
@property (nonatomic, strong) UIImagePickerController *imgPicker;

-(IBAction)stampPhotoButtonPressed:(UIButton *)sender;

@end
