//
//  CustomLabel.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-22.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

/** Custom UITextView drawn on stamped image in edit mode */
#import <UIKit/UIKit.h>
#import "StampedImage.h"

static const CGFloat CUSTOM_LABEL_DEFAULT_FRAME_WIDTH = 10.0f;
static const CGFloat CUSTOM_LABEL_DEFAULT_FRAME_HEIGHT = 40.0f;
static const CGFloat CUSTOM_LABEL_DEFAULT_FONT_SIZE = 30.0f;
static const CGFloat CUSTOM_LABEL_MIN_FONT_SIZE = 20.0f;
static const CGFloat CUSTOM_LABEL_MAX_FONT_SIZE = 150.0f;
static const CGFloat CUSTOM_LABEL_PADDING = 20.0f;

@protocol CustomLabelDelegate;

@interface CustomLabel : UITextView

-(CustomLabel *)initWithStampedImage:(StampedImage *)stampedImage withFrame:(CGRect)frame andText:(NSString *)text andSize:(CGFloat)size andTag:(NSInteger)tag;

-(void)updateFrameForText:(NSString *)string;

@end

@protocol CustomLabelDelegate <UITextViewDelegate>
@optional
-(void)customLabeldidChangeSizeOrPosition:(CustomLabel *)customLabel;
-(void)customLabelIsChangingSizeOrPosition:(CustomLabel *)customLabel;
@end