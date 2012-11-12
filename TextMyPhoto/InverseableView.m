//
//  InverseableView.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-23.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "InverseableView.h"
#import "CustomLabel.h"

#define OPAQUE 1.0f
#define FADE 0.5f

@implementation InverseableView
{
    BOOL _inverseMode;
    CustomLabel *labelBeingPinched;
}

#pragma mark-
#pragma mark properties
-(BOOL)inverseMode
{
    return _inverseMode;
}

-(void)setInverseMode:(BOOL)inverseMode
{
    if (inverseMode != _inverseMode)
    {
        _inverseMode = inverseMode;
        [self setLabelColors];
        [self setNeedsDisplay];
    }
}

-(void)setShouldFade:(BOOL)shouldFade
{
    if (shouldFade != _shouldFade)
    {
        _shouldFade = shouldFade;
        [self setLabelColors];
        [self setNeedsDisplay];
    }
}

-(void)setLabelColors
{
    // Set the color of the label dependent on the inverse mode
    UIColor *curColor = [self.delegate colorForStampedImage];
    UIColor *textColor = self.inverseMode ? [UIColor clearColor] : curColor;
    for (UITextView *textView in self.subviews)
    {
        textView.textColor = textColor;
        textView.alpha = (self.shouldFade) ? FADE : OPAQUE;
        [textView setNeedsDisplay];
    }
}

-(void)setLabelFonts
{
    for (UITextView *textView in self.subviews)
    {
        textView.font = [UIFont fontWithName:[self.delegate fontForStampedImage] size:textView.font.pointSize];
        [textView setNeedsDisplay];
    }
}

-(void)addSubview:(UIView *)view
{
    [super addSubview:view];
    [self setLabelColors];
}

// Make sure to update graphics when new frame is set
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

-(IBAction)didPinchInverseableView:(UIPinchGestureRecognizer *)sender
{
    if ([sender state] == UIGestureRecognizerStateBegan)
    {
        CGPoint touch = [sender locationInView:self];
        for (CustomLabel *label in self.subviews)
            if ([label pointInside:[self convertPoint:touch toView:label] withEvent:nil])
                labelBeingPinched = label;
    }
    else if ([sender state] == UIGestureRecognizerStateChanged)
    {
        if (!labelBeingPinched) // no label was pinched
            return;
        
       CGFloat newFontSize = labelBeingPinched.font.pointSize * sender.scale;
        
        // Do not make the font too small.
        if (newFontSize >= CUSTOM_LABEL_MIN_FONT_SIZE &&
            newFontSize <= CUSTOM_LABEL_MAX_FONT_SIZE)
        {
            // Resize around center of label
            CGPoint oldCenter = labelBeingPinched.center;
            // Calculate new frame and font size
            labelBeingPinched.font = [UIFont fontWithName:labelBeingPinched.font.fontName size:newFontSize];
            labelBeingPinched.center = oldCenter;
            
            // Tell the delagate that we are being resized
            if ([labelBeingPinched.delegate respondsToSelector:@selector(customLabelIsChangingSizeOrPosition:)])
                [((id<CustomLabelDelegate>)labelBeingPinched.delegate) customLabelIsChangingSizeOrPosition:labelBeingPinched];
        }
    }
    else if ([sender state] == UIGestureRecognizerStateEnded)
    {
        // Tell the delagate that we have been resized
        if ([labelBeingPinched.delegate respondsToSelector:@selector(customLabeldidChangeSizeOrPosition:)])
            [((id<CustomLabelDelegate>)labelBeingPinched.delegate) customLabeldidChangeSizeOrPosition:labelBeingPinched];
    }
    [sender setScale:1.0f];
}

- (UIImage*)squareOfSize:(CGSize)size withColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    
    // DEBUG
    if (self.shouldFade)
        CGContextSetAlpha(context, FADE);
    else
        CGContextSetAlpha(context, OPAQUE);
    
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *square = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return square;
}


- (CGImageRef)createMaskWithSize:(CGSize)size shape:(void (^)(void))block
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    block();
    CGImageRef shape = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(shape),
                                        CGImageGetHeight(shape),
                                        CGImageGetBitsPerComponent(shape),
                                        CGImageGetBitsPerPixel(shape),
                                        CGImageGetBytesPerRow(shape),
                                        CGImageGetDataProvider(shape), NULL, false);
    return mask;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.inverseMode)
    {
        UIColor *curColor = [self.delegate colorForStampedImage];
        
        // Create mask and draw every label in the mask with font
        CGImageRef mask = [self createMaskWithSize:rect.size shape:^{
            [[UIColor blackColor] setFill];
            CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
            [[UIColor whiteColor] setFill];
            
            for (UITextView *textView in self.subviews)
            {
                NSString *text = textView.text;
                UIFont *font = textView.font;
                CGPoint origin = textView.frame.origin;
                [text drawAtPoint:origin withFont:font];
            }}];
        
        CGImageRef cutoutRef = CGImageCreateWithMask([self squareOfSize:rect.size withColor:curColor].CGImage, mask);
        CGImageRelease(mask);
        UIImage *cutout = [UIImage imageWithCGImage:cutoutRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
        CGImageRelease(cutoutRef);
        [cutout drawInRect:rect];
    }
}


@end
