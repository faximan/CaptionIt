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

+(BOOL)saveImage:(StampedImage *)image
{
    NSString *path = [self pathForDataFile];
    NSLog(@"Writing image to '%@'", path);
 	
    return [NSKeyedArchiver archiveRootObject:image toFile:path];
}

+(StampedImage *)readImage
{
    NSString *path = [self pathForDataFile];
    NSLog(@"Loading accounts from file '%@'", path);
 	
    StampedImage *image = nil;
    
    image = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return image;
}




@end
