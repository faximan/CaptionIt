//
//  MNMagnifyingView.m
//  MNColorPicker
//

#import "MNMagnifyingView.h"

@implementation MNMagnifyingView

#pragma mark -
#pragma mark Drawing

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	rect = CGRectInset(rect, 2, 2);
	
	if (self.color)
    {
		[self.color setFill];
		CGContextFillEllipseInRect(context, rect);
	}
	
	[[UIColor darkGrayColor] setStroke];
	CGContextSetLineWidth(context,1.0f);
	
	CGContextStrokeEllipseInRect(context, rect);
}

@end
