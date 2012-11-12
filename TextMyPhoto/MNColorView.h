//
//  MNColorView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "StampedImage+Create.h"

@protocol MNColorViewDelegate;


@interface MNColorView : UIView
{
	UIColor *_color;
    NSString *_currentFont;
}

@property (readwrite, weak) id <MNColorViewDelegate> delegate;
@property (readwrite, strong) UIImage *currentImage;
@property (readwrite, strong) NSString *currrentFont;
@property (readwrite, strong) UIColor *color;

@end


@protocol MNColorViewDelegate

- (void)didTouchColorView:(MNColorView *)colorView;

@end
