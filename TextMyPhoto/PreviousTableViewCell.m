//
//  PreviousTableViewCell.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PreviousTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDE_DISTANCE 10.0 // Extra distance that all views should slide to the right 

@implementation PreviousTableViewCell

// Make sure that the image slides to the right more than before
// so that we have the same distance on both sides of the edit movie
-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.2f;
    animation.type = kCATransitionFromLeft;
    
    self.customView.hidden = !editing;
   
    float viewXPos = editing ? SLIDE_DISTANCE : 0.0;
    for( UIView *subview in self.contentView.subviews )
    {
        [subview.layer addAnimation: animation forKey: @"editingFade"];
        
        // Move all subviews 10 points to the right
        subview.frame = CGRectMake(viewXPos, subview.frame.origin.y, subview.frame.size.width, subview.frame.size.height);
        [subview setNeedsDisplay];
    }        
}

@end
