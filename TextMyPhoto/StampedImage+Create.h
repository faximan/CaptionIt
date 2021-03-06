//
//  StampedImage+Create.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-15.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage.h"

#define MAX_ORIGINAL_IMAGE_WIDTH_FOR_RENDERING 800
#define MAX_ORIGINAL_IMAGE_HEIGHT_FOR_RENDERING 800

@interface StampedImage (Create)

+(StampedImage *)createStampedImageWithImageURL:(NSURL *)originalImageURL
                inManagedObjectContext:(NSManagedObjectContext *)context;

-(UIImage *)getThumbImage;
-(void)setUIImageThumbImage:(UIImage *)thumb;
-(void)updateLabel:(UITextView *)label;

@end
