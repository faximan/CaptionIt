//
//  UIImage+Utilities.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-13.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [image drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)getCenterOfImageWithWidth:(CGFloat)width andHeight:(CGFloat) height
{
    CGFloat newOriginX = (self.size.width - width) / 2.0f;
    CGFloat newOriginY = (self.size.height - height) / 2.0f;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(newOriginX*self.scale, newOriginY*self.scale, width*self.scale, height*self.scale));
    
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
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
    
    // Scale down the image to the calculated new size
    return [UIImage imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)];
}

// This is synchronus!
+(UIImage *)getImageFromAssetURL:(NSURL *)url
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];    
    __block UIImage *result = nil;
    __block NSError *assetError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [library assetForURL:url resultBlock:^(ALAsset *asset)
    {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref)
            result = [UIImage imageWithCGImage:iref scale:1.0 orientation:[rep orientation]];
        dispatch_semaphore_signal(sema);
    } failureBlock:^(NSError *error) {
        assetError = error;
        dispatch_semaphore_signal(sema);
    }];
    
    if ([NSThread isMainThread]) {
        while (!result && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if (assetError)
        NSLog(@"Error when fetching from asset library");
    
    return result;
}


+(NSURL *)saveImageToAssetLibrary:(UIImage *)image
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block NSURL *result = nil;
    __block NSError *assetError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    [library writeImageToSavedPhotosAlbum:[image CGImage]
                              orientation:(ALAssetOrientation)[image imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if (error)
                              {
                                  assetError = error;
                                  dispatch_semaphore_signal(sema);
                              }
                              else
                              {
                                  result = assetURL;
                                  dispatch_semaphore_signal(sema);
                              }
                          }];
    
    if ([NSThread isMainThread]) {
        while (!result && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    if (assetError)
        NSLog(@"Error when writing to asset library");
    return result;
}

@end