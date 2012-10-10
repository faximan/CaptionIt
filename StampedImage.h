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

@interface StampedImage : NSObject

@property (nonatomic, strong) UIImage* originalImage;
@property (nonatomic, strong) NSURL *urlToOriginalImage;
@property (nonatomic, strong) NSString *stampedText;

@end
