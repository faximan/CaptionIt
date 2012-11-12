//
//  MNColorView.m
//  MNColorPicker
//

#import "MNColorView.h"
#import "MNMobileFunctions.h"
#import "UIImage+Utilities.h"

#define SAMPLE_TEXT @"Sample"
#define DEFAULT_FONT @"verdana"
static const CGFloat SAMPLE_FONT_SIZE = 30.0f;

@implementation MNColorView
{
    NSAttributedString *attrString;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Initialization code
		self.color = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
        self.currrentFont = DEFAULT_FONT;
    }
    return self;
}

#pragma mark -
#pragma mark Properties

-(UIColor *)color
{
    return _color;
}

- (void)setColor:(UIColor *)color
{
	if (color != _color)
    {
		_color = color;
		[self setNeedsDisplay];
	}
}
-(NSString *)currrentFont
{
    return _currentFont;
}

- (void)setCurrrentFont:(NSString *)currrentFont
{
    if (currrentFont != _currentFont)
    {
        _currentFont = currrentFont;
        // Create attributed string with sample text
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:SAMPLE_TEXT];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSTextAlignmentCenter];
        
        NSRange entireString = NSMakeRange(0, [SAMPLE_TEXT length]);
        
        [as addAttribute:NSParagraphStyleAttributeName value:style range:entireString];
        [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.currrentFont size:SAMPLE_FONT_SIZE] range:entireString];
        attrString = as;
		[self setNeedsDisplay];
    }
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	MNCGContextAddRoundedRectToPath(context,rect,7);
	CGContextClip(context);
	
    [self.currentImage drawInRect:rect];
    
    // Draw centered sample text with the most up to date color
    NSMutableAttributedString *as = [attrString mutableCopy];
    NSRange entireString = NSMakeRange(0, [SAMPLE_TEXT length]);
    [as addAttribute:NSForegroundColorAttributeName value:self.color range:entireString];
    attrString = as;
    [attrString drawInRect:rect];
    
	CGContextRestoreGState(context);
}

@end
