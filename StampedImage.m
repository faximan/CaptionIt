//
//  StampedImage.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-10.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "StampedImage.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation StampedImage

@synthesize originalImage = _originalImage;
@synthesize urlToOriginalImage = _urlToOriginalImage;
@synthesize stampedText = _stampedText;
@synthesize textColor = _textColor;

// Get the image, in the assets library, pointed to by the url property
// Use semaphores to make sure the images is fetched before continuing.
- (void)fetchOriginalImage
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    dispatch_async(queue, ^{
        [assetLibrary assetForURL:_urlToOriginalImage resultBlock:^(ALAsset *asset)
        {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            _originalImage = [UIImage imageWithData:data];
             dispatch_semaphore_signal(sema);
        }
         failureBlock:^(NSError *err) {
             NSLog(@"Error: %@",[err localizedDescription]);
             dispatch_semaphore_signal(sema);
         }];
    });
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self)
    {
        _urlToOriginalImage = [coder decodeObjectForKey:URL_TO_ORIGINAL_IMAGE];
        _stampedText = [coder decodeObjectForKey:STAMPED_TEXT];
        _textColor = [coder decodeObjectForKey:STAMPED_TEXT_COLOR];
        
        [self fetchOriginalImage]; // from the library
        if (!_originalImage) // make sure there is an image associated with this object
            return nil;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_urlToOriginalImage forKey:URL_TO_ORIGINAL_IMAGE];
    [coder encodeObject:_stampedText forKey:STAMPED_TEXT];
    [coder encodeObject:_textColor forKey:STAMPED_TEXT_COLOR];
}

@end
