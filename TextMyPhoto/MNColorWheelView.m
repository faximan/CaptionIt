//
//  MNColorWheelView.m
//  MNColorPicker
//

#import "MNColorWheelView.h"
#import "MNMagnifyingView.h"
#import "UIColor+ColorSpaces.h"
#import "MNBrightnessView.h"

@interface MNColorWheelView ()
- (void)_setAngle:(CGFloat)angle distance:(CGFloat)distance;
@end


@implementation MNColorWheelView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		_colorWheelImage = [[UIImage imageNamed:@"ColorWheel.png"] retain];
		_brightnessImage = [[UIImage imageNamed:@"BrightnessWheel.png"] retain];
		
		_magnifyingView = [[MNMagnifyingView alloc] initWithFrame:CGRectMake(0,0,15,15)];
		[self addSubview:_magnifyingView];
		[_magnifyingView release];
		
		self.clipsToBounds = NO;
    }
    return self;
}

- (void)dealloc {
	[_colorWheelImage release];
	[_brightnessImage release];
    [super dealloc];
}

#pragma mark -
#pragma mark Drawing

- (BOOL)isOpaque {
	return NO;
}

- (void)drawRect:(CGRect)rect {
	[_colorWheelImage drawInRect:rect];
	[_brightnessImage drawInRect:rect blendMode:kCGBlendModeDarken alpha:1-_brightnessView.brightness];
}



#pragma mark -
#pragma mark Properties

@synthesize delegate=_delegate;

- (UIColor *)color {
	return [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightnessView.brightness alpha:1.0f];	
}


- (void)setColor:(UIColor *)color {
	_hue = [color mn_hueComponent];
	_saturation = [color mn_saturationComponent];
	[self _setAngle:_hue distance:_saturation];
	_brightnessView.brightness = [color mn_brightnessComponent];
	[_brightnessView setHue:_hue saturation:_saturation];
	[self setNeedsDisplay];
}


- (void)setBrightnessView:(MNBrightnessView *)brightnessView {
	_brightnessView = brightnessView;
	_brightnessView.delegate = self;
}


- (void)_setAngle:(CGFloat)angle distance:(CGFloat)distance {
	CGRect bounds = [self bounds];
	CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
	CGFloat radius = bounds.size.width / 2.0f - 8.0f;
	
	CGFloat a = angle * 2.0f * M_PI;
	CGFloat r = distance * radius;
	
	center.x += cos(a) * r;
	center.y += sin(a) * r * -1;
	_magnifyingView.center =center;
}


#pragma mark -
#pragma mark Event Handling

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	
	CGRect bounds = self.bounds;
	CGFloat radius = bounds.size.width / 2.0f - 8.0f;
	CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
	
	CGFloat dx = point.x - center.x;
	CGFloat dy = point.y - center.y;
	CGFloat distance = sqrt (dx * dx + dy * dy);
	
	if (distance <= radius) {
		return YES;
	} else {
		return NO;
	}
	
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	
	
	CGRect bounds = self.bounds;
	CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
	CGFloat radius = bounds.size.width / 2.0f - 8.0f;
	CGFloat dx = point.x - center.x;
	CGFloat dy = point.y - center.y;
	CGFloat distance = sqrt(dx * dx + dy * dy) / radius;
	
	CGFloat angle = atan2(dy,dx) / 2.0 / M_PI;
	if (angle < 0) angle += 1;
	angle = 1-angle;
	

	if (distance <= 1) {
		_magnifyingView.center = point;
		_hue = angle;
		_saturation = distance;
	} else {
		_hue = angle;
		_saturation = 1;
		[self _setAngle:angle distance:1];
	}
	[_brightnessView setHue:_hue saturation:_saturation];
	[self.delegate colorWheelView:self didChangeColor:self.color];

}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[self touchesMoved:touches withEvent:event];
}


#pragma mark -
#pragma mark MNBrightnessView Delegate

- (void)brightnessView:(MNBrightnessView *) brightnessView didChangeBrightness:(CGFloat)brightness {
	[self setNeedsDisplay];
	[self.delegate colorWheelView:self didChangeColor:self.color];
}



@end