//
//  MNColorPicker.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "MNColorWheelView.h"
#import "MNBrightnessView.h"
#import "MNColorView.h"

#define COLORVIEW_FRAME_PORTRAIT CGRectMake(35, 20, 250, 40)
#define COLORWHEELVIEW_FRAME_PORTRAIT CGRectMake(35, 80, 250, 250)
#define BRIGHTNESSVIEW_FRAME_PORTRAIT CGRectMake(35, 360, 250, 30)
#define COLORVIEW_FRAME_LANDSCAPE CGRectMake(50, 10, 40, 250)
#define COLORWHEELVIEW_FRAME_LANDSCAPE CGRectMake(120,10, 250, 250)
#define BRIGHTNESSVIEW_FRAME_LANDSCAPE CGRectMake(400,10, 30, 250)


@protocol MNColorPickerDelegate;

@interface MNColorPicker : UIViewController <MNColorWheelViewDelegate>
{
	MNColorView *_colorView;
	MNColorWheelView *_colorWheelView;
	MNBrightnessView *_brightnessView;
    UIImage *_currentImage;
    NSString *_currentFont;
}

@property (weak, nonatomic) id<MNColorPickerDelegate> delegate;
@property (strong) UIImage* currentImage;
@property (strong) NSString* currentFont;
@property (strong) UIColor *color;
@property (getter=isContinuous) BOOL continuous;

@end


@protocol MNColorPickerDelegate <NSObject>

@required
- (void)colorPicker:(MNColorPicker *)picker didFinishWithColor:(UIColor *)color;

@optional
- (void)colorPicker:(MNColorPicker *)picker didChangeColor:(UIColor *)color;

@end
