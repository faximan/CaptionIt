//
//  CustomLabel.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-22.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "CustomLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomLabel

-(CustomLabel *)initWithStampedImage:(StampedImage *)stampedImage withFrame:(CGRect)frame andText:(NSString *)text andSize:(CGFloat)size andTag:(NSInteger)tag
{
    if (self = [super initWithFrame:frame])
    {
        self.textColor = stampedImage.color;
        self.text = text;
        self.tag = tag;
        
        self.font = [UIFont fontWithName:stampedImage.font size:size];
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.backgroundColor = [UIColor clearColor];
        self.scrollEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        // DEBUG: Make sure to show bounds
        self.layer.borderColor = [[UIColor redColor] CGColor];
        self.layer.borderWidth = 1.0f;
        
        // Remove useless padding.
        self.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
        
        // Add pan gesture recognizer
        UIGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveCustomLabel:)];
        [self addGestureRecognizer:panGR];
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

-(void)setFont:(UIFont *)font
{
    if (font != self.font)
    {
        [super setFont:font];
        [self updateFrameForText:self.text];
    }
}

-(void)updateFrameForText:(NSString *)string
{
    // Remove useless padding.
    self.contentInset = UIEdgeInsetsMake(-8,-8,-8,-8);
    
    // Calculate new frame size
    CGRect oldFrame = self.frame;
    oldFrame.size = [string sizeWithFont:self.font];
    oldFrame.size.height += CUSTOM_LABEL_PADDING;
    oldFrame.size.width += CUSTOM_LABEL_PADDING;
    self.frame = oldFrame;
}

// When textview is moved
-(void)didMoveCustomLabel:(UIPanGestureRecognizer *)sender
{    
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translatedPoint = [sender translationInView:self.superview];
        
        [self setCenter:CGPointMake(self.center.x + translatedPoint.x, self.center.y+translatedPoint.y)];
        [sender setTranslation:CGPointZero inView:self.superview];

        if ([self.delegate respondsToSelector:@selector(customLabelIsChangingSizeOrPosition:)])
            [((id<CustomLabelDelegate>)self.delegate) customLabelIsChangingSizeOrPosition:self];
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(customLabeldidChangeSizeOrPosition:)])
            [((id<CustomLabelDelegate>)self.delegate) customLabeldidChangeSizeOrPosition:self];
    }
}

@end
