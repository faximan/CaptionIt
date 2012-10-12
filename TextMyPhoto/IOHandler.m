//
//  IOHandler.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-11.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "IOHandler.h"

@implementation IOHandler

// Path to the data file in the app's Documents directory
+(NSString *)pathForDataFile
{
    NSArray* documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = nil;
 	
    if (documentDir)
        path = documentDir[0];
    
    return [NSString stringWithFormat:@"%@/%@", path, @"data.bin"];
}

+(BOOL)saveImage:(StampedImage *)image forIndex:(NSNumber *)index
{
    NSString *path = [self pathForDataFile];
    
    NSArray *images = [self readImages];
    if (!images) // no previously stored images
    {
        images = @[image];
    }
    else
    {
        if ([index unsignedIntegerValue] >= [images count]) // append at the end
            images = [images arrayByAddingObject:image];
        else // replace a current image
        {
            NSMutableArray *mutImages = [images mutableCopy];
            mutImages[[index unsignedIntegerValue]] = image;
            images = mutImages;
        }
    }
    return [NSKeyedArchiver archiveRootObject:images toFile:path];
}

+(NSArray *)readImages
{
    NSString *path = [self pathForDataFile];
    NSObject *images = nil;
    
    images = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if (![images isKindOfClass:[NSArray class]]) // corrupt data
        return nil;
    return (NSArray *)images;
}

@end
