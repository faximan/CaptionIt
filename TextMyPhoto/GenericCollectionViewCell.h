//
//  GenericCollectionViewCell.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImage;
@property (nonatomic, weak) IBOutlet UIView *whiteView;
@property (nonatomic, weak) IBOutlet UIView* highlightFade;
@property (nonatomic, weak) IBOutlet UILabel* label;
@property (nonatomic, weak) IBOutlet UIButton* deleteButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

// Returns the height of a cell in the table view
+(CGFloat)cellHeight;
+(CGFloat)cellWidth;

@end
