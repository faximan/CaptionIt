//
//  MNColorView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>
#import "StampedImage+Create.h"

@protocol MNColorViewDelegate;


@interface MNColorView : UIView
{
    StampedImage *_stampedImage;
	UIColor *_color;
}

@property (readwrite, weak) id <MNColorViewDelegate> delegate;
@property (readwrite, strong) StampedImage* stampedImage;
@property (readwrite, strong) UIColor *color;

@end


@protocol MNColorViewDelegate

- (void)didTouchColorView:(MNColorView *)colorView;

@end
