//
//  GenericTableViewCell.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat MAX_CELL_HEIGHT = 150.0f;
static const CGFloat SLIDE_DISTANCE = 10.0; // Extra distance that all views should slide to the right
static const CGFloat ANIMATION_LENGTH = 0.2f; // Length of animation when editing (fade to white tint and slide to right).

@implementation GenericTableViewCell

+(CGFloat)cellHeight
{
    return MAX_CELL_HEIGHT;
}

+(CGFloat)cellWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

// Show highlight tint when selected
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    self.highlightFade.hidden = !highlighted;
    [self.highlightFade setNeedsDisplay];
}

// Make sure that the image slides to the right more than before
// so that we have the same distance on both sides of the edit movie
-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    CATransition *animation = [CATransition animation];
    animation.duration = ANIMATION_LENGTH;
    animation.type = kCATransitionFromLeft;
    
    self.editFade.hidden = !editing;

    // Calculate new view position based on editing mode
    float viewXPos = editing ? SLIDE_DISTANCE : 0.0;
    
    // Move the view if it is not already in the right position
    for( UIView *subview in self.contentView.subviews )
    {
        // Move the view if it is not already in the right position
        if (subview.frame.origin.x != viewXPos)
        {
            [subview.layer addAnimation: animation forKey: @"editingFade"];
        
            CGRect frame = subview.frame;
            frame.origin.x = viewXPos;
            subview.frame = frame;
            [subview setNeedsDisplay];
        }
    }
}
@end
