//
//  GenericCollectionViewCell.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat MAX_CELL_HEIGHT = 150.0f;
static const CGFloat SLIDE_DISTANCE = 10.0; // Extra distance that all views should slide to the right
static const CGFloat ANIMATION_LENGTH = 0.2f; // Length of animation when editing (fade to white tint and slide to right).

@implementation GenericCollectionViewCell

+(CGFloat)cellHeight
{
    return MAX_CELL_HEIGHT;
}

+(CGFloat)cellWidth
{
    return MAX_CELL_HEIGHT;
}

// Show highlight tint when selected
-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.highlightFade.hidden = !highlighted;
    [self.highlightFade setNeedsDisplay];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
        [self.spinner startAnimating];
}

@end
