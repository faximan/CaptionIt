//
//  StampedImage+Create.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-15.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage+Create.h"
#import "Label.h"

#define DEFAULT_FONT @"verdana"
#define DEFAULT_COLOR [UIColor whiteColor]
#define DEFAULT_INVERTED NO
#define DEFAULT_FADE NO

@implementation StampedImage (Create)

+(StampedImage *)createStampedImageWithImageURL:(NSURL *)originalImageURL
                      inManagedObjectContext:(NSManagedObjectContext *)context
{
    StampedImage* stampedImage = nil;
    stampedImage = [NSEntityDescription insertNewObjectForEntityForName:@"StampedImage"                                                     inManagedObjectContext:context];
    
    // Set default font and color
    stampedImage.font = DEFAULT_FONT;
    stampedImage.color = DEFAULT_COLOR;
    stampedImage.inverted = DEFAULT_INVERTED;
    stampedImage.shouldFade = DEFAULT_FADE;
    stampedImage.originalImageURL = [originalImageURL absoluteString];
    
    return stampedImage;
}

// Finds the right label in the database and updates it accordingly
// inserting a new label if there is no match
-(void)updateLabel:(UITextView *)label
{
    NSAssert(label, nil);
    Label *curLabel = nil; // the label to be updated
    
    // Search for this label to see if it already exists
    for (Label *iLabel in self.labels)
        if (iLabel.nbr == @(label.tag))
            curLabel = iLabel;
    
    // Delete label if there is no text
    if ([label.text isEqualToString:@""])
    {
        if (curLabel)
        {
            [self removeLabelsObject:curLabel];
            [self.managedObjectContext deleteObject:curLabel];
        }
        return;
    }
    
    if (!curLabel) // create new label
        curLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:[self managedObjectContext]];

    // Update label
    curLabel.nbr = @(label.tag);
    curLabel.x = @(label.frame.origin.x);
    curLabel.y = @(label.frame.origin.y);
    curLabel.height = @(label.frame.size.height);
    curLabel.width = @(label.frame.size.width);
    curLabel.fontSize = @(label.font.pointSize);
    curLabel.text = label.text;
    curLabel.stampedImage = self;
    self.dateModified = [NSDate date];
}

-(void)setUIImageThumbImage:(UIImage *)thumb
{
    NSData *data = UIImagePNGRepresentation(thumb);
    self.thumbImage = data;
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

-(void)setInverted:(NSNumber *)inverted
{
    if (inverted != self.inverted)
    {
        [self willChangeValueForKey:@"inverted"];
        [self setPrimitiveValue:inverted forKey:@"inverted"];
        [self didChangeValueForKey:@"inverted"];
        self.dateModified = [NSDate date];
    }
}

-(void)setShouldFade:(NSNumber *)shouldFade
{
    if (shouldFade != self.shouldFade)
    {
        [self willChangeValueForKey:@"shouldFade"];
        [self setPrimitiveValue:shouldFade forKey:@"shouldFade"];
        [self didChangeValueForKey:@"shouldFade"];
        self.dateModified = [NSDate date];
    }
}

-(void)setOriginalImageURL:(NSString *)originalImageURL
{
    if (originalImageURL != self.originalImageURL)
    {
        [self willChangeValueForKey:@"originalImageURL"];
        [self setPrimitiveValue:originalImageURL forKey:@"originalImageURL"];
        [self didChangeValueForKey:@"originalImageURL"];
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

-(UIImage *)getThumbImage
{
    [self willAccessValueForKey:@"thumbImage"];
    UIImage *image = [UIImage imageWithData:self.thumbImage];
    [self didAccessValueForKey:@"thumbImage"];
    return image;
}

@end
