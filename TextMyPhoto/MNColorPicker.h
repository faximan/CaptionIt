//
//  MNColorPicker.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "MNColorWheelView.h"
#import "MNBrightnessView.h"
#import "MNColorView.h"
#import "StampedImage.h"

@protocol MNColorPickerDelegate;

@interface MNColorPicker : UIViewController <MNColorWheelViewDelegate>
{
	MNColorView *_colorView;
	MNColorWheelView *_colorWheelView;
	MNBrightnessView *_brightnessView;
    StampedImage *_stampedImage;
}

@property (weak, nonatomic) id<MNColorPickerDelegate> delegate;
@property (strong) StampedImage* stampedImage;
@property (strong) UIColor *color;
@property (getter=isContinuous) BOOL continuous;

@end


@protocol MNColorPickerDelegate <NSObject>

@required
- (void)colorPicker:(MNColorPicker *)picker didFinishWithColor:(UIColor *)color;

@optional
- (void)colorPicker:(MNColorPicker *)picker didChangeColor:(UIColor *)color;

@end
