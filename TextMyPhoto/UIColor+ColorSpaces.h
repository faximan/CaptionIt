//
//  NSColor+WebColor.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>


@interface UIColor (ColorSpaces) 

+ (UIColor *)mn_colorWithWebColor: (NSString *)colorString;
- (NSString *)mn_webColor;

#pragma mark -
#pragma mark RGB


- (BOOL)mn_canProvideRGBColor;
- (CGColorSpaceModel)mn_colorSpaceModel;
- (CGFloat)mn_redComponent;
- (CGFloat)mn_greenComponent;
- (CGFloat)mn_blueComponent;
- (CGFloat)mn_alphaValue;


#pragma mark -
#pragma mark HSB

- (CGFloat)mn_hueComponent;
- (CGFloat)mn_saturationComponent;
- (CGFloat)mn_brightnessComponent;
	

@end
