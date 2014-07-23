//
//  PNPLocationSettingViewController.m
//  
//
//  Created by Horace Williams on 6/25/14.
//
//

#import "PNPLocationSettingViewController.h"
#import "PNPAppDelegate.h"
#import "PNPStaticShit.h"
@interface PNPLocationSettingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *saveLocationButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation PNPLocationSettingViewController

- (void)viewDidLoad {
    self.mapView.showsUserLocation = YES;
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [super viewDidAppear:animated];
}

- (IBAction)saveLocation:(id)sender {
    [self saveHomeLocationToUserDefaults:self.mapView.centerCoordinate];
    [self triggerHomeLocationUpdatedNotification];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)triggerHomeLocationUpdatedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:[PNPStaticShit homeLocationUpdatedNotif] object:nil userInfo:nil];
}

- (void)saveHomeLocationToUserDefaults:(CLLocationCoordinate2D)location {
    NSLog(@"save current location lat: %f", self.mapView.centerCoordinate.latitude);
    NSLog(@"save current location long: %f", self.mapView.centerCoordinate.longitude);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.mapView.centerCoordinate.latitude forKey:@"homeLocationLatitude"];
    [defaults setFloat:self.mapView.centerCoordinate.longitude forKey:@"homeLocationLongitude"];
    [defaults synchronize];
    NSLog(@"updated home location is: lat: %f, long: %f", [defaults floatForKey:@"homeLocationLatitude"], [defaults floatForKey:@"homeLocationLongitude"]);
}

//- (void)registerForLocationNotifs:(CLLocationCoordinate2D)location {
//    CLLocationDistance distance = 150.0;
//    CLCircularRegion *homeRegion = [[CLCircularRegion alloc] initWithCenter:location radius:distance identifier:@"homeRegion"];
//    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
//        NSLog(@"monitoring available");
//        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
//            NSLog(@"monitoring authorized");
//            PNPAppDelegate *appDelegate = (PNPAppDelegate *)[[UIApplication sharedApplication] delegate];
//            [appDelegate registerForLocationNotification:homeRegion];
//        }
//    }
//}
@end
