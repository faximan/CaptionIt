//
//  UIImage+Utilities.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-13.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)getCenterOfImageWithWidth:(CGFloat)width andHeight:(CGFloat) height
{
    CGFloat newWidth = (self.size.width - width) / 2.0f;
    CGFloat newHeight = (self.size.height - height) / 2.0f;    
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(newWidth, newHeight, width, height));
    return [UIImage imageWithCGImage:imageRef];
}

+(CGRect)frameForImage:(UIImage*)image inViewAspectFit:(UIView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    
    if(imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

+(UIImage *)modifyImage:(UIImage *)image toFillRectWithWidth:(CGFloat)width andHeight:(CGFloat)height
{
       // Do not scale image if it is already small
    if (image.size.height <= height || image.size.width <= width)
        return image;
    
    // Scale down image to be a good fit for the cell and do not store a bigger image than necessary
    CGFloat heightScale = height / image.size.height;
    CGFloat widthScale = width / image.size.width;
    
    CGFloat newWidth, newHeight;
    
    if (heightScale * image.size.width < width)
    {
        newWidth = width;
        newHeight = image.size.height * widthScale;
    }
    else
    {
        newWidth = image.size.width * heightScale;
        newHeight = height;
    }
    
    // Scale down the image to the calculated new size and crop out the center part to get an image as big as the thumb should be
    return [[UIImage imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)] getCenterOfImageWithWidth:width andHeight:height];
}

@end