//
//  MyNavigationControllerViewController.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-10-06.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "MyNavigationControllerViewController.h"

@implementation MyNavigationControllerViewController

-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end