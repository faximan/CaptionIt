//
//  LoadingView.m
//  Caption it!
//
//  Created by Alexander Faxå on 2012-11-16.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation LoadingView

-(void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    [self setNeedsDisplay];
}


@end
