//
//  PNPLocationTracker.m
//  PNPDemo
//
//  Created by Horace Williams on 7/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPLocationTracker.h"
#import "PNPStaticShit.h"

@interface PNPLocationTracker ()
@property (nonatomic, strong) CLLocationManager* locationManager;
@end

@implementation PNPLocationTracker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager.delegate = self;
        [self registerForHomeLocationUpdateNotifications];
    }
    return self;
}

- (void)registerForHomeLocationUpdateNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerForLocationNotifications)
                                                 name:[PNPStaticShit homeLocationUpdatedNotif]
                                               object:nil];

}

- (void)registerForLocationNotifications {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    if (CLLocationCoordinate2DIsValid([self savedHomeLocation])) {
        CLRegion *homeRegion = [[CLCircularRegion alloc] initWithCenter:[self savedHomeLocation]
                                                                 radius:300.0
                                                             identifier:[NSString stringWithFormat:@"%f, %f", [self savedHomeLocation].latitude, [self savedHomeLocation].longitude]];
        [self.locationManager startMonitoringForRegion:homeRegion];
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
}

- (CLLocationCoordinate2D)savedHomeLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float latitude = [defaults floatForKey:[PNPStaticShit homeLocationLatKey]];
    float longitude = [defaults floatForKey:[PNPStaticShit homeLocationLongKey]];
    
    CLLocationCoordinate2D homeCoordinate;
    if (latitude && longitude) {
        homeCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    }
    return homeCoordinate;
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"entered region");
    [self triggerEnteredRegionEvents];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"exited region");
}

- (void)triggerEnteredRegionEvents {
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.alertBody = @"entered region";
    localNotification.alertAction = @"Open";
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber]+1;
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
    
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}



#pragma mark location manager status updates

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"UPNP DEMO LOCATION FAILED");
    NSLog(@"error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"location alert"
                                message:@"location manager failed with error"
                               delegate:nil
                      cancelButtonTitle:@"cancel"
                      otherButtonTitles:nil] show];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"UPNP DEMO LOCATION MANAGER UPDATED");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"UPNP DEMO monitoringDidFailForRegion");
    NSLog(@"error: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"monitoring failed"
                                message:@"monitoringDidFailForRegion"
                               delegate:nil
                      cancelButtonTitle:@"cancel"
                      otherButtonTitles:nil] show];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"UPNP DEMO monitoring didStartMonitoringForRegion");
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"did determine state for region %@", region);
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"did range beacons");
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"ranging beacons did fail %@", error);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"did pause location updates");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    NSLog(@"did resume location updates");
}

@end
