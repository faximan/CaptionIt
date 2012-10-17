//
//  GenericTableViewCell.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericTableViewCell: UITableViewCell

@property (nonatomic, strong) UIImage *cellImage;
@property (nonatomic, weak) IBOutlet UIView* editFade;
@property (nonatomic, weak) IBOutlet UIView* highlightFade;

@property (nonatomic, strong) NSAttributedString *label;

@end
