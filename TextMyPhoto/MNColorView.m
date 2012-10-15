//
//  MNColorView.m
//  MNColorPicker
//

#import "MNColorView.h"
#import "MNMobileFunctions.h"


@implementation MNColorView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.color = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)dealloc {
	self.color = nil;
    [super dealloc];
}



#pragma mark -
#pragma mark Properties

@synthesize delegate=_delegate;
@synthesize color=_color;

- (void)setColor:(UIColor *)color {
	if (color != _color) {
		[_color release];
		_color = [color retain];
		[self setNeedsDisplay];
	}
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	MNCGContextAddRoundedRectToPath(context,rect,7);
	CGContextClip(context);
	
	[self.color setFill];
	CGContextFillRect(context, rect);
	
	CGContextRestoreGState(context);
	
}


@end
