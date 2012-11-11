//
//  StampedImage+Create.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-15.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage.h"

@interface StampedImage (Create)

+(StampedImage *)createStampedImageWithImageURL:(NSURL *)originalImageURL
                inManagedObjectContext:(NSManagedObjectContext *)context;

-(UIImage *)getThumbImage;
-(void)setUIImageThumbImage:(UIImage *)thumb;
-(void)updateLabel:(UITextView *)label;

@end
