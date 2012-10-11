//
//  MNColorView.h
//  MNColorPicker
//

#import <UIKit/UIKit.h>

@protocol MNColorViewDelegate;


@interface MNColorView : UIView {
	id <MNColorViewDelegate> _delegate;
	UIColor *_color;
}

@property (readwrite, assign) id <MNColorViewDelegate> delegate;
@property (readwrite, retain) UIColor *color;

@end


@protocol MNColorViewDelegate

- (void)didTouchColorView:(MNColorView *)colorView;

@end
