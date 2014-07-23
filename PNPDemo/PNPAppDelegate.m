//
//  PNPAppDelegate.m
//  PNPDemo
//
//  Created by Horace Williams on 6/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPAppDelegate.h"
#import "PNPMediaDeviceLibrary.h"
#import "PNPLocationSettingViewController.h"
#import "PNPLocationTracker.h"

@interface PNPAppDelegate ()
@property (nonatomic, strong) PNPLocationTracker* locationTracker;
@end

@implementation PNPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[PNPMediaDeviceLibrary sharedLibrary] scanForMediaDevices];
    [self.locationTracker registerForLocationNotifications];
    NSLog(@"saved home location is %f, %f", [self.locationTracker savedHomeLocation].latitude, [self.locationTracker savedHomeLocation].longitude);
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"UPNP Will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    NSLog(@"UPNP Will Terminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (PNPLocationTracker*)locationTracker {
    if (!_locationTracker) {
        _locationTracker = [[PNPLocationTracker alloc] init];
    }
    return  _locationTracker;
}

@end
