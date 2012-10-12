//
//  PhotoBrowserDataSource.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "PhotoBrowserDataSource.h"
#import "IOHandler.h"
#import "StampedImage.h"

@interface PhotoBrowserDataSource ()

@property (strong) StampedImage *image;

@end

@implementation PhotoBrowserDataSource

-(id)init
{
    if (self = [super init])
    {
        _image = [IOHandler readImage];
    }
    return self;
}

#pragma mark KTPhotoBrowserDataSourceDelegate
- (NSInteger)numberOfPhotos
{
    return (_image) ? 3 : 0;
}

- (UIImage *)imageAtIndex:(NSInteger)index;
{
    return _image.originalImage;
}

- (UIImage *)thumbImageAtIndex:(NSInteger)index
{
    return _image.originalImage;
}

@end
