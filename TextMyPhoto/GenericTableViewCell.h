//
//  GenericTableViewCell.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericTableViewCell: UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImage;
@property (nonatomic, weak) IBOutlet UIView* editFade;
@property (nonatomic, weak) IBOutlet UIView* highlightFade;

@end
