//
//  StampedImage+Create.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-15.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage+Create.h"

@implementation StampedImage (Create)

+(StampedImage *)createStampedImageWithImage:(UIImage *)originalImage
                inManagedObjectContext:(NSManagedObjectContext *)context
{
    StampedImage* stampedImage = nil;
    stampedImage = [NSEntityDescription insertNewObjectForEntityForName:@"StampedImage"                                                     inManagedObjectContext:context];
    [stampedImage setImage:originalImage];
    return stampedImage;
}

// Custom setters to make sure date modified is kept accurate
- (void)setImage:(UIImage *)originalImage
{
    NSData *data = UIImagePNGRepresentation(originalImage);
    self.originalImage = data;
}

-(void)setLabel:(NSString *)label
{
    if (label != self.label)
    {
        [self willChangeValueForKey:@"label"];
        [self setPrimitiveValue:label forKey:@"label"];
        [self didChangeValueForKey:@"label"];
        [self setPrimitiveValue:[NSDate date] forKey:@"dateModified"];
    }
}

-(void)setColor:(id)color
{
    if (color != self.color)
    {
        [self willChangeValueForKey:@"color"];
        [self setPrimitiveValue:color forKey:@"color"];
        [self didChangeValueForKey:@"color"];
        [self setPrimitiveValue:[NSDate date] forKey:@"dateModified"];
    }
}

-(void)setOriginalImage:(NSData *)originalImage
{
    if (originalImage != self.originalImage)
    {
        [self willChangeValueForKey:@"originalImage"];
        [self setPrimitiveValue:originalImage forKey:@"originalImage"];
        [self didChangeValueForKey:@"originalImage"];
        [self setPrimitiveValue:[NSDate date] forKey:@"dateModified"];
    }
}

- (UIImage *)getOriginalImage
{
    [self willAccessValueForKey:@"originalImage"];
    UIImage *image = [UIImage imageWithData:self.originalImage];
    [self didAccessValueForKey:@"originalImage"];
    return image;
}

@end
