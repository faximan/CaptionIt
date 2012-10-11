//
//  StampedImage.h
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-10.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

/** This class contains a model for a stamped image, or an image to be stamped. It contains, in addition to the actual image, text, frames or other things that the user has added in the edit window. 
 
    This model should be written so that it can easily be serialized to permanent memory. */

#import <Foundation/Foundation.h>

// Constant NSString used for serialization
#define URL_TO_ORIGINAL_IMAGE  @"urlToOriginalImage"
#define STAMPED_TEXT @"stampedText"
#define STAMPED_TEXT_COLOR @"textColor"

@interface StampedImage : NSObject <NSCoding>

@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) NSURL *urlToOriginalImage;
@property (nonatomic, strong) NSString *stampedText;
@property (nonatomic, strong) UIColor *textColor;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
