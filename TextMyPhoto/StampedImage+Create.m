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

// Finds the right label in the database and updates it accordingly
// inserting a new label if there is no match
-(void)updateLabel:(UITextView *)label
{
    NSSet *result = [self fetchObjectsForEntityName:@"Label" withPredicate:
     @"(stampedImage = %@) AND (nbr = %d)", self, label.tag];
    
    if (result && [result count] < 2)
    {
        Label *newLabel = nil;
        if (![result count])
        {
            // insert new object
            newLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:[self managedObjectContext]];
        }
        else
        {
            newLabel = [result anyObject]; // Should only be one
        }
        // Update label
        newLabel.nbr = @(label.tag);
        newLabel.x = @(label.frame.origin.x);
        newLabel.y = @(label.frame.origin.y);
        newLabel.height = @(label.frame.size.height);
        newLabel.width = @(label.frame.size.width);
        newLabel.fontSize = @(label.font.pointSize);
        newLabel.text = label.text;
        newLabel.stampedImage = self;
        self.dateModified = [NSDate date];
        
        NSLog(@"The current stamped image contains %d labels", [self.labels count]);
    }
    else
    {
        NSLog(@"Error! Handle this");
        NSAssert(NO,nil);
    }
}

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSSet *)fetchObjectsForEntityName:(NSString *)newEntityName
                       withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:newEntityName inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
                                               arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert([stringOrPredicate isKindOfClass:[NSPredicate class]],
                      @"Second parameter passed to %s is of unexpected class %@",
                      sel_getName(_cmd), [stringOrPredicate class]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return [NSSet setWithArray:results];
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
