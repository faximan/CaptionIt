//
//  MNBrightnessView.h
//  MNColorPicker
//

#import "MNBrightnessView.h"
#import "MNMagnifyingView.h"
#import "UIColor+ColorSpaces.h"
#import "MNMobileFunctions.h"


@interface MNBrightnessView ()
@end


@implementation MNBrightnessView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

		_magnifyingView = [[MNMagnifyingView alloc] initWithFrame:CGRectMake(0,0,15,15)];
		[self addSubview:_magnifyingView];
		[_magnifyingView release];
		
		self.clipsToBounds = NO;
		_interfaceOrientation = [UIDevice currentDevice].orientation;
		
		self.backgroundColor = [UIColor clearColor];
		
    }
    return self;
}



#pragma mark -
#pragma mark Properties

@synthesize delegate = _delegate;

- (CGFloat)brightness {
	CGFloat brightness;
	
	if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
		brightness =  1.f - (_magnifyingView.center.x / self.bounds.size.width);
	} else {
		brightness =  1.f - (_magnifyingView.center.y / self.bounds.size.height);
	}
	if (brightness > 1.0f) brightness = 1.0f;
	if (brightness < 0.0f) brightness = 0.0f;
	return brightness;
}

- (void)setBrightness:(CGFloat)brightness {

	brightness = 1-brightness;
	
	CGPoint center;
	if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
		center.x = (self.bounds.size.width * brightness);
		center.y = CGRectGetMidY(self.bounds);
	} else {
		center.x = CGRectGetMidX(self.bounds);
		center.y = (self.bounds.size.height * brightness);
	}
	_magnifyingView.center = center;
	[_magnifyingView setNeedsDisplay];
}


#pragma mark -
#pragma mark Methods


- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation {
	
	UIColor *startColor = [UIColor colorWithHue:hue saturation:saturation brightness:1.0f alpha:1.0f];
	UIColor *endColor = [UIColor colorWithHue:hue saturation:saturation brightness:0.0f alpha:1.0f];
	
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = {[startColor mn_redComponent], [startColor mn_greenComponent], [startColor mn_blueComponent], 1.f,  // Start color = white
		[endColor mn_redComponent], [endColor mn_greenComponent], [endColor mn_blueComponent], 1.0f }; // End color = black
	CGGradientRelease(_gradient);
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	_gradient = CGGradientCreateWithColorComponents (rgb, components, locations, 2);
	CGColorSpaceRelease(rgb);
	
	[self setNeedsDisplay];
	
}


- (void)updateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
	_interfaceOrientation = interfaceOrientation;
	self.brightness = self.brightness;
	[self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	MNCGContextAddRoundedRectToPath(context,rect,6);
	
	CGContextClip(context);
	if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
		CGContextDrawLinearGradient(context, _gradient, CGPointMake(0,0), CGPointMake(self.bounds.size.width,0), 0);
	} else {
		CGContextDrawLinearGradient(context, _gradient, CGPointMake(0,0), CGPointMake(0,self.bounds.size.height), 0);		
	}
	CGContextRestoreGState(context);
	
}


- (void)dealloc {
	CGGradientRelease(_gradient);
    [super dealloc];
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	
	UITouch* touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGRect bounds = self.bounds;
	
	if (UIInterfaceOrientationIsPortrait(_interfaceOrientation)) {
		if (point.x < bounds.origin.x) point.x = bounds.origin.x;
		if (point.x > CGRectGetMaxX(bounds)) point.x = CGRectGetMaxX(bounds);
		point.y = CGRectGetMidY(self.bounds);
	} else {
		if (point.y < bounds.origin.y) point.y = bounds.origin.y;
		if (point.y > CGRectGetMaxY(bounds)) point.y = CGRectGetMaxY(bounds);
		point.x = CGRectGetMidX(self.bounds);
	}

	
	_magnifyingView.center = point;
	[_magnifyingView setNeedsDisplay];
	
	[self.delegate brightnessView:self didChangeBrightness:self.brightness];
	[self setNeedsDisplay];
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[self touchesMoved:touches withEvent:event];
}

@end
