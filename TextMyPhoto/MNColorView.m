//
//  MNColorView.m
//  MNColorPicker
//

#import "MNColorView.h"
#import "MNMobileFunctions.h"
#import "UIImage+Utilities.h"

#define SAMPLE_TEXT @"Sample"
static const CGFloat SAMPLE_FONT_SIZE = 30.0f;

@implementation MNColorView
{
    UIImage *sampleImage;
    NSAttributedString *attrString;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // Initialization code
		self.color = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
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

-(StampedImage *)stampedImage
{
    return _stampedImage;
}

- (void)setStampedImage:(StampedImage *)stampedImage
{
	if (stampedImage != _stampedImage)
    {
		_stampedImage = stampedImage;
        sampleImage = [UIImage modifyImage:stampedImage.getOriginalImage toFillRectWithWidth:self.bounds.size.width andHeight:self.bounds.size.height];
        
        // Create attributed string with sample text
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:SAMPLE_TEXT];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        
        NSRange entireString = NSMakeRange(0, [SAMPLE_TEXT length]);
        
        [style setAlignment:NSTextAlignmentCenter];
        [as addAttribute:NSParagraphStyleAttributeName value:style range:entireString];
        [as addAttribute:NSFontAttributeName value:[UIFont fontWithName:_stampedImage.font size:SAMPLE_FONT_SIZE] range:entireString];
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
	
    // Draw image
    [sampleImage drawInRect:rect];
    
    // Draw centered sample text with the most up to date color
    NSMutableAttributedString *as = [attrString mutableCopy];
    NSRange entireString = NSMakeRange(0, [SAMPLE_TEXT length]);
    [as addAttribute:NSForegroundColorAttributeName value:self.color range:entireString];
    attrString = as;
    [attrString drawInRect:rect];
    
	CGContextRestoreGState(context);
}

@end
