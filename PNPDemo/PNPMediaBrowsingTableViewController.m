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
#import "PNPMediaDeviceLibrary.h"
#import "PNPStaticShit.h"

@interface PNPMediaBrowsingTableViewController () <UPnPDBObserver, UITableViewDataSource>
@end

@implementation PNPMediaBrowsingTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self findMediaServers];
    self.tableView.dataSource = self;
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
    NSLog(@"upnp updated");
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
