//
//  MNColorWheelView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "MNBrightnessView.h"

@class MNMagnifyingView;
@protocol MNColorWheelViewDelegate;

@interface MNColorWheelView : UIView  <MNBrightnessViewDelegate>{
	UIImage *_colorWheelImage;
	UIImage *_brightnessImage;
	MNMagnifyingView *_magnifyingView;
    MNBrightnessView *_brightnessView;
	
	CGFloat _hue;
	CGFloat _saturation;
}

@property (nonatomic, weak) id <MNColorWheelViewDelegate> delegate;
@property (readwrite, weak) UIColor *color;
- (void)setBrightnessView:(MNBrightnessView *)brightnessView;

@end


@protocol MNColorWheelViewDelegate <NSObject>

@required
- (void)colorWheelView:(MNColorWheelView *)colorWheelView didChangeColor:(UIColor *)color;

@end
