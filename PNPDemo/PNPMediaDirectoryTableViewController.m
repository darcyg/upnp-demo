//
//  PNPMediaDirectoryTableViewController.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPMediaDirectoryTableViewController.h"
#import "PNPMediaDirectoryLookup.h"
#import "MediaServer1BasicObject.h"

@interface PNPMediaDirectoryTableViewController ()
@property BasicUPnPDevice *mediaDevice;
@property NSString *rootDirectoryName;
@property NSArray *mediaItems;
@end

@implementation PNPMediaDirectoryTableViewController

- (instancetype)initWithMediaDevice:(BasicUPnPDevice *)device rootDirectoryIdentifier:(NSString *)dirName {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.rootDirectoryName = dirName;
        self.mediaDevice = device;
    }
    return self;
}

- (void)viewDidLoad
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    NSLog(@"dirVC did load");
    [super viewDidLoad];
    NSLog(@"loading media items");
    [self loadMediaItems];
    NSLog(@"done loading media items");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mediaItems count];
}

- (void)loadMediaItems {
    self.mediaItems = [[[PNPMediaDirectoryLookup alloc] initWithMediaDevice:self.mediaDevice rootDirectoryIdentifier:self.rootDirectoryName] mediaItems];
    NSLog(@"media items %@", self.mediaItems);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    MediaServer1BasicObject *mediaItem = (MediaServer1BasicObject *)[self.mediaItems objectAtIndex:indexPath.row];
    cell.textLabel.text = mediaItem.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaServer1BasicObject *mediaItem = (MediaServer1BasicObject *)[self.mediaItems objectAtIndex:indexPath.row];
    
    if (mediaItem.isContainer) {
        PNPMediaDirectoryTableViewController *next = [[PNPMediaDirectoryTableViewController alloc] initWithMediaDevice:self.mediaDevice rootDirectoryIdentifier:mediaItem.objectID];
        [self.navigationController pushViewController:next animated:YES];
    } else {
        NSLog(@"selected non-container item!");
    }
}


@end
