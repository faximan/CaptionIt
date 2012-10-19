//
//  StampedImage.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StampedImage : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSData * originalImage;
@property (nonatomic, retain) NSData * thumbImage;
@property (nonatomic, retain) NSString * font;

@end
