//
//  UIImage+Tint.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-13.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//
/** Add a tint to an uiimage. */

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *)tintedImageUsingColor:(UIColor *)tintColor;

@end