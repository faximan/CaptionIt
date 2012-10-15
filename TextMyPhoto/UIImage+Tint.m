//
//  UIImage+Tint.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-13.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

// Add a tint to an UIImage
- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContext(self.size);
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end