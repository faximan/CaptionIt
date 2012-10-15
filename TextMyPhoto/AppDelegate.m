//
//  AppDelegate.m
//  TextMyPhoto
//
//  Created by Alexander Faxå on 2012-08-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "AppDelegate.h"
#import "MyNavigationControllerViewController.h"
#import "LaunchMenuViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set custom color of toolbars
    [[UIToolbar appearance] setTintColor:[UIColor grayColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor grayColor]];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)saveDatabase
{
    // Save changes to Core Data database
    UIViewController *rc = self.window.rootViewController;
    if ([rc isKindOfClass:[MyNavigationControllerViewController class]])
    {
        MyNavigationControllerViewController *nc = (MyNavigationControllerViewController *)rc;
        for(UIViewController *ctrl in nc.viewControllers)
        {
            if ([ctrl respondsToSelector:@selector(saveDatabase)])
                [(LaunchMenuViewController *)ctrl saveDatabase];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveDatabase];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Save changes to core data database
    [self saveDatabase];
}

@end
