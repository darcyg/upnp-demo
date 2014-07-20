//
//  PNPMediaBrowsingTableViewController.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPMediaBrowsingTableViewController.h"
#import "UPnPDB.h"
#import "BasicUPnPDevice.h"
#import "UPnPManager.h"
#import "PNPMediaDirectoryTableViewController.h"
#import "ESTBeaconManager.h"
#import "PNPMediaDeviceLibrary.h"
#import "PNPStaticShit.h"

@interface PNPMediaBrowsingTableViewController () <UPnPDBObserver, UITableViewDataSource, ESTBeaconManagerDelegate, CLLocationManagerDelegate>
@property ESTBeaconManager *beaconManager;
@property CLLocationManager *locManager;
@end

@implementation PNPMediaBrowsingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self findMediaServers];
    self.tableView.dataSource = self;
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.locManager = [[CLLocationManager alloc] init];
    self.beaconManager.delegate = self;
    self.locManager.delegate = self;
    
    NSLog(@"monitoring availbale: %d", [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]);
    NSLog(@"auth status %d", [CLLocationManager authorizationStatus]);
    
    CLBeaconRegion *lamansionBeacon = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID major:0 minor:0 identifier:@"LamansionBeacon"];
    
    [self.locManager startMonitoringForRegion:lamansionBeacon];
    
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    [self.beaconManager startEstimoteBeaconsDiscoveryForRegion:region];

    [self.beaconManager startRangingBeaconsInRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"entered region");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"started monitoring");
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"ranged beacons");
}

- (void)beaconManager:(ESTBeaconManager *)manager didDiscoverBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    NSLog(@"discovered beacons");
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region {
    NSLog(@"%@", beacons);
    NSLog(@"ranged beacons");
    if([beacons count] > 0)
    {
        NSLog(@"got beacons");
        // beacon array is sorted based on distance
        // closest beacon is the first one
        ESTBeacon* closestBeacon = [beacons objectAtIndex:0];
        
        switch (closestBeacon.proximity)
        {
            case CLProximityUnknown:
                NSLog(@"unknown");
                break;
            case CLProximityImmediate:
                NSLog(@"immediate");
                break;
            case CLProximityNear:
                NSLog(@"near");
                break;
            case CLProximityFar:
                NSLog(@"far");
                break;
            default:
                break;
        }
    }

}

- (void)beaconManager:(ESTBeaconManager *)manager didFailDiscoveryInRegion:(ESTBeaconRegion *)region {
    NSLog(@"failed discovery");
}

- (void)beaconManager:(ESTBeaconManager *)manager monitoringDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoring failed");
}

- (void)beaconManager:(ESTBeaconManager *)manager rangingBeaconsDidFailForRegion:(ESTBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"ranging beacons did fail");
    NSLog(@"error: %@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[[PNPMediaDeviceLibrary sharedLibrary] mediaDevices] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell for row at indexpath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaItemTableViewCell" forIndexPath:indexPath];
    BasicUPnPDevice *device = (BasicUPnPDevice *)[[[PNPMediaDeviceLibrary sharedLibrary] mediaDevices] objectAtIndex:indexPath.row];
    cell.textLabel.text = device.friendlyName;
    
    return cell;
}

- (IBAction)playDrake:(id)sender {
    if ([[PNPMediaDeviceLibrary sharedLibrary] sonosPlayer]) {
        NSLog(@"tryna play drake");
        [[[PNPMediaDeviceLibrary sharedLibrary] sonosPlayer].avTransport SetAVTransportURIWithInstanceID:@"0"
                                                                                              CurrentURI:[PNPStaticShit drakeUrl]
                                                                                      CurrentURIMetaData:@""];
        [[[PNPMediaDeviceLibrary sharedLibrary] sonosPlayer].avTransport PlayWithInstanceID:@"0" Speed:@"1"];
//        [[[PNPMediaDeviceLibrary sharedLibrary] sonosPlayer] play];

    } else {
        NSLog(@"dont have sonos cant play");
        [self findMediaServers];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row %d", indexPath.row);
    BasicUPnPDevice *device = [[[PNPMediaDeviceLibrary sharedLibrary] mediaDevices] objectAtIndex:indexPath.row];
    PNPMediaDirectoryTableViewController *next = [[PNPMediaDirectoryTableViewController alloc] initWithMediaDevice:device rootDirectoryIdentifier:@"0"];
    [self.navigationController pushViewController:next animated:YES];
}
-(void)UPnPDBUpdated:(UPnPDB*)sender{
//    NSLog(@"upnp updated");
    NSLog(@"devices count is %d", [[[PNPMediaDeviceLibrary sharedLibrary] mediaDevices] count]);
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

- (void)UPnPDBWillUpdate:(UPnPDB *)sender { };

- (void)findMediaServers {
    NSLog(@"find media servers");
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    [db addObserver:(UPnPDBObserver *)self];
}

@end
