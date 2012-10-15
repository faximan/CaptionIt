//
//  UIImage+Utilities.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-13.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//
/** Add a tint to an uiimage or resize it. */

#import <UIKit/UIKit.h>

@interface UIImage (Utilities)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (CGRect)frameForImage:(UIImage*)image inViewAspectFit:(UIView*)imageView;
@end