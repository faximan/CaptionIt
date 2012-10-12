//
//  PhotoBrowserDataSource.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"

@interface PhotoBrowserDataSource : NSObject <KTPhotoBrowserDataSource>

- (NSInteger)numberOfPhotos;

// Implement either these, for synchronous images…
- (UIImage *)imageAtIndex:(NSInteger)index;
- (UIImage *)thumbImageAtIndex:(NSInteger)index;

/*
// …or these, for asynchronous images.
- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView;
- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView;
*/

/*
- (NSInteger)thumbsPerRow;
- (UIColor *)imageBackgroundColor;
- (CGSize)thumbSize;
- (BOOL)thumbsHaveBorder;
*/
 
@end
