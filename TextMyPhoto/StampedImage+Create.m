//
//  StampedImage+Create.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-15.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage+Create.h"

#define DEFAULT_FONT @"verdana"
#define DEFAULT_COLOR [UIColor whiteColor]

@implementation StampedImage (Create)

+(StampedImage *)createStampedImageWithImage:(UIImage *)originalImage
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    StampedImage* stampedImage = nil;
    stampedImage = [NSEntityDescription insertNewObjectForEntityForName:@"StampedImage"                                                     inManagedObjectContext:context];
    [stampedImage setUIImageOriginalImage:originalImage];
    
    // Set default font and color
    stampedImage.font = DEFAULT_FONT;
    stampedImage.color = DEFAULT_COLOR;
    
    return stampedImage;
}

// Custom setters to make sure date modified is kept accurate
- (void)setUIImageOriginalImage:(UIImage *)originalImage
{
    NSData *data = UIImagePNGRepresentation(originalImage);
    self.originalImage = data;
}

-(void)setUIImageThumbImage:(UIImage *)thumb
{
    NSData *data = UIImagePNGRepresentation(thumb);
    self.thumbImage = data;
}

-(void)setLabel:(NSString *)label
{
    if (label != self.label)
    {
        [self willChangeValueForKey:@"label"];
        [self setPrimitiveValue:label forKey:@"label"];
        [self didChangeValueForKey:@"label"];
        self.dateModified = [NSDate date];
    }
}

-(void)setColor:(id)color
{
    if (color != self.color)
    {
        [self willChangeValueForKey:@"color"];
        [self setPrimitiveValue:color forKey:@"color"];
        [self didChangeValueForKey:@"color"];
        self.dateModified = [NSDate date];
    }
}

-(void)setFont:(NSString *)font
{
    if (font != self.font)
    {
        [self willChangeValueForKey:@"font"];
        [self setPrimitiveValue:font forKey:@"font"];
        [self didChangeValueForKey:@"font"];
        self.dateModified = [NSDate date];
    }
}

-(void)setOriginalImage:(NSData *)originalImage
{
    if (originalImage != self.originalImage)
    {
        [self willChangeValueForKey:@"originalImage"];
        [self setPrimitiveValue:originalImage forKey:@"originalImage"];
        [self didChangeValueForKey:@"originalImage"];
        self.dateModified = [NSDate date];
    }
}

-(void)setThumbImage:(NSData *)thumbImage
{
    if (thumbImage != self.thumbImage)
    {
        [self willChangeValueForKey:@"thumbImage"];
        [self setPrimitiveValue:thumbImage forKey:@"thumbImage"];
        [self didChangeValueForKey:@"thumbImage"];
        self.dateModified = [NSDate date];
    }
}

- (UIImage *)getOriginalImage
{
    [self willAccessValueForKey:@"originalImage"];
    UIImage *image = [UIImage imageWithData:self.originalImage];
    [self didAccessValueForKey:@"originalImage"];
    return image;
}

-(UIImage *)getThumbImage
{
    [self willAccessValueForKey:@"thumbImage"];
    UIImage *image = [UIImage imageWithData:self.thumbImage];
    [self didAccessValueForKey:@"thumbImage"];
    return image;
}

@end
