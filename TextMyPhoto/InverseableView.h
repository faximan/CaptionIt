//
//  InverseableView.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-23.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InversableViewDelegate;

@interface InverseableView : UIView <NSCopying>

@property (nonatomic) BOOL inverseMode;
@property (nonatomic) BOOL shouldFade;
@property (nonatomic, weak) id<InversableViewDelegate> delegate;

// Set all label fonts to be that of the current image
-(void)setLabelFonts;

// Set all label colors to be that of the current image
-(void)setLabelColors;

@end

@protocol InversableViewDelegate <NSObject>
/* Return the color of the current label */
-(UIColor *)colorForStampedImage;
-(NSString *)fontForStampedImage;
@end