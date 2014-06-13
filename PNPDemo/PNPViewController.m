//
//  PNPViewController.m
//  PNPDemo
//
//  Created by Horace Williams on 6/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPViewController.h"
#import "UPnPDB.h"
#import "UPnPManager.h"
#import "MediaServerBasicObjectParser.h"


@interface PNPViewController () <UPnPDBObserver>
@property (nonatomic, strong) NSArray *mDevices;
@property (nonatomic, strong) NSMutableArray *mPlaylist;
@end

@implementation PNPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    self.mDevices = [db rootDevices];
    NSLog(@"observe DB!");
    [db addObserver:(UPnPDBObserver *)self];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    self.mPlaylist = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    NSLog(@"UPnPDBWillUpdate %d", [self.mDevices count]);
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"UPnPDBUpdated %d", [self.mDevices count]);
    NSLog(@"devices: %@", self.mDevices);
    for (BasicUPnPDevice *device in self.mDevices) {
        NSLog(@"urn is %@", device.urn);
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"]){
            MediaServer1Device *server = (MediaServer1Device*)device;
            
            //pass by reference strings to read output
            NSMutableString *outResult = [[NSMutableString alloc] init];
            NSMutableString *outNumberReturned = [[NSMutableString alloc] init];
            NSMutableString *outTotalMatches = [[NSMutableString alloc] init];
            NSMutableString *outUpdateID = [[NSMutableString alloc] init];

            
            [[server contentDirectory] BrowseWithObjectID:@"0"
                                               BrowseFlag:@"BrowseDirectChildren"
                                                   Filter:@"*"
                                            StartingIndex:@"0"
                                           RequestedCount:@"0"
                                             SortCriteria:@"+dc:title'"
                                                OutResult:outResult
                                        OutNumberReturned:outNumberReturned
                                          OutTotalMatches:outTotalMatches
                                              OutUpdateID:outUpdateID];
            
            NSData *didl = [outResult dataUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"preparing to read playlist");
            
            [self.mPlaylist removeAllObjects]; //clear playlist so we can add to it
            MediaServerBasicObjectParser *parser = [[MediaServerBasicObjectParser alloc] initWithMediaObjectArray:self.mPlaylist];
            [parser parseFromData:didl];
            NSLog(@"playlist count is %d", [self.mPlaylist count]);
            NSLog(@"playlist is %@", self.mPlaylist);
            
            for (MediaServer1BasicObject *item in self.mPlaylist) {
                NSLog(@"playlist item title is %@", item.title);
            }
        }

    }

}

@end
