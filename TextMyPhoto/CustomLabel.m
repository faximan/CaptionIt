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

-(UITextView *)initWithStampedImage:(StampedImage *)stampedImage withFrame:(CGRect)frame andText:(NSString *)text andSize:(CGFloat)size andTag:(NSInteger)tag
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
        
        // Add pan gesture recognizer
        UIGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didMoveCustomLabel:)];
        UIGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchCustomLabel:)];
        [self addGestureRecognizer:panGR];
        [self addGestureRecognizer:pinchGR];
    }
    return self;
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

-(void)didPinchCustomLabel:(UIPinchGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan || [sender state] == UIGestureRecognizerStateChanged)
    {
        CGFloat newFontSize = self.font.pointSize * sender.scale;
            
        // Do not make the font too small.
        if (newFontSize >= CUSTOM_LABEL_MIN_FONT_SIZE)
        {
            // Resize around center of label
            CGPoint oldCenter = self.center;
            
            // Calculate new frame and font size
            CGRect oldFrame = self.frame;
            UIFont *newFont = [UIFont fontWithName:self.font.fontName size:newFontSize];
            oldFrame.size = [self.text sizeWithFont:newFont];
            oldFrame.size.height += CUSTOM_LABEL_PADDING;
            oldFrame.size.width += CUSTOM_LABEL_PADDING;
            self.frame = oldFrame;
            self.font = newFont;
            
            self.center = oldCenter;
            
            if ([self.delegate respondsToSelector:@selector(customLabelIsChangingSizeOrPosition:)])
                [((id<CustomLabelDelegate>)self.delegate) customLabelIsChangingSizeOrPosition:self];
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(customLabeldidChangeSizeOrPosition:)])
            [((id<CustomLabelDelegate>)self.delegate) customLabeldidChangeSizeOrPosition:self];
    }

    [sender setScale:1.0f];
}
@end
