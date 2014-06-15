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

@interface PNPMediaBrowsingTableViewController () <UPnPDBObserver, UITableViewDataSource>
@property (nonatomic, strong) NSArray *mediaDevices;
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
    NSLog(@"num rows in section %d", [self.mediaDevices count]);
    return [self.mediaDevices count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell for row at indexpath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaItemTableViewCell" forIndexPath:indexPath];
    BasicUPnPDevice *device = (BasicUPnPDevice *)[self.mediaDevices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.friendlyName;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected row %d", indexPath.row);
    BasicUPnPDevice *device = [self.mediaDevices objectAtIndex:indexPath.row];
    PNPMediaDirectoryTableViewController *next = [[PNPMediaDirectoryTableViewController alloc] initWithMediaDevice:device rootDirectoryIdentifier:@"0"];
    [self.navigationController pushViewController:next animated:YES];
}
-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"upnp updated");
    NSLog(@"devices count is %d", [self.mediaDevices count]);
    [self.tableView reloadData];
}

- (void)UPnPDBWillUpdate:(UPnPDB *)sender { };

- (void)findMediaServers {
    NSLog(@"find media servers");
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    self.mediaDevices = [db rootDevices];
    [db addObserver:(UPnPDBObserver *)self];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
}

@end
