//
//  Label.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-23.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StampedImage;

@interface Label : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * nbr;
@property (nonatomic, retain) NSNumber * fontSize;
@property (nonatomic, retain) StampedImage *stampedImage;

@end
