//
//  ThumbsPhotoControllerViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-12.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "ThumbsPhotoControllerViewController.h"
#import "PhotoBrowserDataSource.h"

@interface ThumbsPhotoControllerViewController ()
@property (strong) PhotoBrowserDataSource *ds;
@end

@implementation ThumbsPhotoControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Previous projects";
    
	_ds = [[PhotoBrowserDataSource alloc] init];
    [self setDataSource:_ds];
}

@end
