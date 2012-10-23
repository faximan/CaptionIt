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

// Resizes a image to the given size
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

// Crops out the center part of the image with passed width and height
-(UIImage *)getCenterOfImageWithWidth:(CGFloat)width andHeight:(CGFloat) height;

// Returns a CGRect that corresponds to the actual part of the screen containing image when added with Aspect Fit into imageview.
+ (CGRect)frameForImage:(UIImage*)image inViewAspectFit:(UIView*)imageView;

// Returns an image scaled to fit perfectly in a rect with passed
// width an height
+(UIImage *)modifyImage:(UIImage *)image toFillRectWithWidth:(CGFloat)width andHeight:(CGFloat)height;
@end