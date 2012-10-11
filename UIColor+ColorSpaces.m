//
//  NSColor+WebColor.m
//  MNColorPicker
//

#import "UIColor+ColorSpaces.h"


@implementation UIColor (ColorSpaces)

+ (UIColor *)mn_colorWithWebColor: (NSString *)colorString {

	NSUInteger length = [colorString length];
	if (length > 0) {
		// remove prefixed #
		colorString = [colorString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"#"]];
		length = [colorString length];
		
		// calculate substring ranges of each color
		// FFF or FFFFFF
		NSRange redRange, blueRange, greenRange;
		if (length == 3) {
			redRange = NSMakeRange(0, 1);
			greenRange = NSMakeRange(1, 1);
			blueRange = NSMakeRange(2, 1);
		} else if (length == 6) {
			redRange = NSMakeRange(0, 2);
			greenRange = NSMakeRange(2, 2);
			blueRange = NSMakeRange(4, 2);
		} else {
			return nil;
		}

		// extract colors
		NSUInteger redComponent, greenComponent, blueComponent; 
		BOOL valid = YES;
		NSScanner *scanner = [NSScanner scannerWithString:[colorString substringWithRange:redRange]];
		valid = [scanner scanHexInt:&redComponent];
		
		scanner = [NSScanner scannerWithString:[colorString substringWithRange:greenRange]];
		valid = ([scanner scanHexInt:&greenComponent] && valid);

		scanner = [NSScanner scannerWithString:[colorString substringWithRange:blueRange]];
		valid = ([scanner scanHexInt:&blueComponent] && valid);

		if (valid) {
			return [UIColor colorWithRed:redComponent/255.0 green:greenComponent/255.0 blue:blueComponent/255.0 alpha:1.0f];
		}
	}
	
	return nil;
}

- (NSString *)mn_webColor {
	
	if (![self mn_canProvideRGBColor]) return nil;
	
	return [NSString stringWithFormat:@"#%02X%02X%02X", ((NSUInteger)([self mn_redComponent] * 255)), 
			((NSUInteger)([self mn_greenComponent] * 255)), ((NSUInteger)([self mn_blueComponent] * 255))];
	
}



#pragma mark -
#pragma mark RGB

// The RGB code is based on:
// http://arstechnica.com/apple/guides/2009/02/iphone-development-accessing-uicolor-components.ars

- (BOOL)mn_canProvideRGBColor {
	return (([self mn_colorSpaceModel] == kCGColorSpaceModelRGB) || ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome));
}

- (CGColorSpaceModel)mn_colorSpaceModel {
	return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (CGFloat)mn_redComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[0];
}

- (CGFloat)mn_greenComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[1];
}

- (CGFloat)mn_blueComponent {
	NSAssert ([self mn_canProvideRGBColor], @"Must be a RGB color to use -red, -green, -blue");
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	if ([self mn_colorSpaceModel] == kCGColorSpaceModelMonochrome) return c[0];
	return c[2];
}

- (CGFloat)mn_alphaValue {
	const CGFloat *c = CGColorGetComponents(self.CGColor);
	return c[CGColorGetNumberOfComponents(self.CGColor)-1];
}


#pragma mark -
#pragma mark HSV

// conversion: http://en.wikipedia.org/wiki/HSL_and_HSV
// calculates HSV values

- (CGFloat)mn_hueComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat min = MIN(MIN(r,g),b);
	CGFloat max = MAX(MAX(r,g),b);
	
	CGFloat hue = 0;
	if (max==min) {
		hue = 0;
	} else if (max == r) {
		hue = fmod((60 * (g-b)/(max-min) + 360), 360);
	} else if (max == g) {
		hue = (60 * (b-r)/(max-min) + 120);
	} else if (max == b) {
		hue = (60 * (r-g)/(max-min) + 240);
	}
	return hue / 360;
}


- (CGFloat)mn_saturationComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat min = MIN(MIN(r,g),b);
	CGFloat max = MAX(MAX(r,g),b);
	
	if (max==0) {
		return 0;
	} else {
		return (max-min)/(max);
	}
}

- (CGFloat)mn_brightnessComponent {
	if (![self mn_canProvideRGBColor]) return 0;
	CGFloat r = [self mn_redComponent];
	CGFloat g = [self mn_greenComponent];
	CGFloat b = [self mn_blueComponent];
	
	CGFloat max = MAX(MAX(r,g),b);
	
	return max;
}


@end
