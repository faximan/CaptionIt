//
//  InverseableView.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-23.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InversableViewDelegate;

@interface InverseableView : UIView

@property (nonatomic) BOOL inverseMode;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<InversableViewDelegate> delegate;

@end

@protocol InversableViewDelegate <NSObject>
/* Return the color of the current label */
-(UIColor *)colorForStampedImage;
@end