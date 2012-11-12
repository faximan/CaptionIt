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


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
		_colorWheelImage = [UIImage imageNamed:@"ColorWheel.png"].CGImage;
		_brightnessImage = [UIImage imageNamed:@"BrightnessWheel.png"].CGImage;
		
		_magnifyingView = [[MNMagnifyingView alloc] initWithFrame:CGRectMake(0,0,15,15)];
		[self addSubview:_magnifyingView];
		
		self.clipsToBounds = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing

- (BOOL)isOpaque
{
	return NO;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, _colorWheelImage);
    CGContextSetAlpha(context, 1-_brightnessView.brightness);
    CGContextDrawImage(context, rect, _brightnessImage);
}

#pragma mark -
#pragma mark Properties

- (UIColor *)color
{
	return [UIColor colorWithHue:_hue saturation:_saturation brightness:_brightnessView.brightness alpha:1.0f];	
}


- (void)setColor:(UIColor *)color
{
	_hue = [color mn_hueComponent];
	_saturation = [color mn_saturationComponent];
	[self _setAngle:_hue distance:_saturation];
	_brightnessView.brightness = [color mn_brightnessComponent];
	[_brightnessView setHue:_hue saturation:_saturation];
	[self setNeedsDisplay];
}


- (void)setBrightnessView:(MNBrightnessView *)brightnessView
{
	_brightnessView = brightnessView;
	_brightnessView.delegate = self;
}


- (void)_setAngle:(CGFloat)angle distance:(CGFloat)distance
{
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	CGRect bounds = self.bounds;
	CGFloat radius = bounds.size.width / 2.0f - 8.0f;
	CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
	
	CGFloat dx = point.x - center.x;
	CGFloat dy = point.y - center.y;
	CGFloat distance = sqrt (dx * dx + dy * dy);
	
	return distance <= radius;	
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
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

	if (distance <= 1)
    {
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

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self touchesMoved:touches withEvent:event];
}

#pragma mark -
#pragma mark MNBrightnessView Delegate

- (void)brightnessView:(MNBrightnessView *) brightnessView didChangeBrightness:(CGFloat)brightness
{
	[self setNeedsDisplay];
	[self.delegate colorWheelView:self didChangeColor:self.color];
}

@end