//
//  MNColorPicker.m
//  MNColorPicker
//

#import "MNColorPicker.h"
#import "MNBrightnessView.h"
#import "UIColor+ColorSpaces.h"


@interface MNColorPicker ()

- (void)_layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@implementation MNColorPicker

#pragma mark -
#pragma mark Loading & Memory Management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;{
	self = [super initWithNibName:nil bundle:nil];
	if (self != nil) {
		self.color = [UIColor whiteColor];
        self.stampedImage = nil;
		self.continuous = NO;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.contentSizeForViewInPopover = CGSizeMake(320, 420);
		}		
	}
	return self;
}


- (void)loadView {
	[super loadView];
	
	self.view = [[UIView alloc] initWithFrame:CGRectZero];
	self.view.backgroundColor = [UIColor colorWithRed:0.169 green:0.185 blue:0.200 alpha:1.000];
	[self.view sizeToFit];
    
	_colorView = [[MNColorView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:_colorView];
	
	_colorWheelView = [[MNColorWheelView alloc] initWithFrame:CGRectZero];
	_colorWheelView.delegate = self;
	[self.view addSubview:_colorWheelView];
	[_colorWheelView setNeedsDisplay];
	
	_brightnessView = [[MNBrightnessView alloc] initWithFrame:CGRectZero];
	[self.view addSubview:_brightnessView];
	[_colorWheelView setBrightnessView:_brightnessView];
	
	
	self.title = NSLocalizedStringFromTable(@"Color Picker",@"ColorPicker",@"Title");
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didPressDone)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(didPressCancel)];

}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _layoutViewsForInterfaceOrientation:self.interfaceOrientation];
	_colorView.color = self.color;
    _colorView.stampedImage = self.stampedImage;
	_colorWheelView.color = self.color;
	[_brightnessView setHue:[self.color mn_hueComponent] saturation:[self.color mn_saturationComponent]];
	_brightnessView.brightness = [self.color mn_brightnessComponent];
}

#pragma mark -
#pragma mark Properties
- (StampedImage *)stampedImage
{
    return _stampedImage;
}

-(void)setStampedImage:(StampedImage *)stampedImage
{
    if (_stampedImage != stampedImage)
    {
        _stampedImage = stampedImage;
        _colorView.stampedImage = stampedImage;
    }
}

#pragma mark -
#pragma mark Layout

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return YES;
	} else {
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self _layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[_brightnessView setNeedsDisplay]; // update the orientation
}


- (void)_layoutViewsForInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {

	if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
		_colorView.frame = CGRectMake(35, 20, 250, 40);
		_colorWheelView.frame = CGRectMake(35, 80, 250, 250);
		_brightnessView.frame = CGRectMake(35, 360, 250, 30);
	} else {
		_colorView.frame = CGRectMake(50, 10, 40, 250);
		_colorWheelView.frame = CGRectMake(120,10, 250, 250);
		_brightnessView.frame = CGRectMake(400,10, 30, 250);
	}
	[_colorView setNeedsDisplay];
	[_brightnessView updateToInterfaceOrientation:interfaceOrientation];
}

#pragma mark -
#pragma mark Actions

- (void)didPressDone {
	[self.delegate colorPicker:self didFinishWithColor:self.color];
}

- (void)didPressCancel {
	[self.delegate colorPicker:self didFinishWithColor:nil];
}


#pragma mark -
#pragma mark MNColorWheelView Delegate


- (void)colorWheelView:(MNColorWheelView *)colorWheelView didChangeColor:(UIColor *)color {
	self.color = color;
	_colorView.color = color;
	
	if (self.continuous && [self.delegate respondsToSelector:@selector(colorPicker:didChangeColor:)]) {
		[self.delegate performSelector:@selector(colorPicker:didChangeColor:) withObject:self withObject:self.color];
	}
}




@end
