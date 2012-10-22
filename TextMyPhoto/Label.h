//
//  Label.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-19.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class StampedImage;

@interface Label : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) StampedImage *stampedImage;

@end
