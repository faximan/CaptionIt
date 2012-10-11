//
//  MNBrightnessView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
@class MNMagnifyingView;
@protocol MNBrightnessViewDelegate;

@interface MNBrightnessView : UIView {
	id <MNBrightnessViewDelegate> _delegate;
	CGGradientRef _gradient;
	MNMagnifyingView *_magnifyingView;
	UIInterfaceOrientation _interfaceOrientation;
}

// Properties
@property (assign) id <MNBrightnessViewDelegate> delegate;
@property (readwrite) CGFloat brightness;

// methods
- (void)setHue:(CGFloat)hue saturation:(CGFloat)saturation;
- (void)updateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation;

@end


@protocol MNBrightnessViewDelegate <NSObject>

@required
- (void)brightnessView:(MNBrightnessView *) brightnessView didChangeBrightness:(CGFloat)brightness;

@end
