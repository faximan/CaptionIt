//
//  MNColorWheelView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "MNBrightnessView.h"

@class MNMagnifyingView;
@protocol MNColorWheelViewDelegate;

@interface MNColorWheelView : UIView  <MNBrightnessViewDelegate>{
	id <MNColorWheelViewDelegate> _delegate;
	UIImage *_colorWheelImage;
	UIImage *_brightnessImage;
	MNMagnifyingView *_magnifyingView;
	MNBrightnessView *_brightnessView;
	
	CGFloat _hue;
	CGFloat _saturation;
}

@property (nonatomic, assign) id <MNColorWheelViewDelegate> delegate;
@property (readwrite, assign) UIColor *color;
- (void)setBrightnessView:(MNBrightnessView *)brightnessView;

@end


@protocol MNColorWheelViewDelegate <NSObject>

@required
- (void)colorWheelView:(MNColorWheelView *)colorWheelView didChangeColor:(UIColor *)color;

@end
