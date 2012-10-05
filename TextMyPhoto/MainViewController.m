//
//  MainViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

enum actionSheetType
{
    ACTIONSHEET_TYPE_CHOOSE_ORIGIN,
    ACTIONSHEET_TYPE_CHOOSE_SHARE
};

#pragma mark For adding the text to the image

/** Add the passed text to the current image
  * Code copied from http://iphonesdksnippets.com/post/2009/05/05/Add-text-to-image-(UIImage).aspx */
-(void)addTextToCurrentImage:(NSString *)text
{
    // Get the current image
    UIImage* img = nil;//_imageView.image;
    if (!img)
    {
        // Something went wrong, there is no image to add text to.
        //[self showAlertWithTitle:@"Error" andMessage:@"Something went wrong when trying to add text to this image"];
        return;
    }
    
    int w = img.size.width;
    int h = img.size.height;
    //lon = h - lon;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1);
	
    char* myText = (char *)[text cStringUsingEncoding:NSASCIIStringEncoding];// "05/05/09";
    CGContextSelectFont(context, "Arial", 20, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
	
    
    //rotate text
    //CGContextSetTextMatrix(context, CGAffineTransformMakeRotation( -M_PI/4 ));
	
    CGContextShowTextAtPoint(context, 15, h/2, myText, strlen(myText));
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    //[_imageView setImage:[UIImage imageWithCGImage:imageMasked]];
}
@end
