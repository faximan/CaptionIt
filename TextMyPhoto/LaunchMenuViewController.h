//
//  LaunchMenuViewController.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-05.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviousTableViewController.h"

@interface LaunchMenuViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, PreviousTableViewControllerDelegate>

// Save current changes to core data database
-(void)saveDatabase;

@end
