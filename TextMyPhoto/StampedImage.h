//
//  StampedImage.h
//  Caption it!
//
//  Created by Alexander Faxå on 2012-11-22.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Label;

@interface StampedImage : NSManagedObject

@property (nonatomic, retain) id color;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * font;
@property (nonatomic, retain) NSNumber * inverted;
@property (nonatomic, retain) NSString * originalImageURL;
@property (nonatomic, retain) NSNumber * shouldFade;
@property (nonatomic, retain) NSData * thumbImage;
@property (nonatomic, retain) NSNumber * filterType;
@property (nonatomic, retain) NSSet *labels;
@end

@interface StampedImage (CoreDataGeneratedAccessors)

- (void)addLabelsObject:(Label *)value;
- (void)removeLabelsObject:(Label *)value;
- (void)addLabels:(NSSet *)values;
- (void)removeLabels:(NSSet *)values;

@end
