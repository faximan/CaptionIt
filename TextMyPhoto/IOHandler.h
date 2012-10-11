//
//  IOHandler.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-11.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StampedImage.h"

@interface IOHandler : NSObject

+(BOOL)saveImage:(StampedImage *)image;
+(StampedImage *)readImage;

@end
