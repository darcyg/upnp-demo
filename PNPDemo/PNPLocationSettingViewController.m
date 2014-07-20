//
//  PNPLocationSettingViewController.m
//  
//
//  Created by Horace Williams on 6/25/14.
//
//

#import "PNPLocationSettingViewController.h"

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
    NSLog(@"save current location lat: %f", self.mapView.centerCoordinate.latitude);
    NSLog(@"save current location long: %f", self.mapView.centerCoordinate.longitude);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.mapView.centerCoordinate.latitude forKey:@"homeLocationLatitude"];
    [defaults setFloat:self.mapView.centerCoordinate.longitude forKey:@"homeLocationLongitude"];
    [defaults synchronize];
    
    NSLog(@"updated home location is: lat: %f, long: %f", [defaults floatForKey:@"homeLocationLatitude"], [defaults floatForKey:@"homeLocationLongitude"]);
    [self.navigationController popViewControllerAnimated:YES];
}
@end
