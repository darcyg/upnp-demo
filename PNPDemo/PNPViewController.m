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
            NSArray *results = [self exploreMediaDirectoryRecursively:@"0" onServer:server];
            NSLog(@"found %d items", [results count]);
        }

    }
}

- (NSArray *)exploreMediaDirectoryRecursively:(NSString *)rootItemObjectID onServer:(MediaServer1Device *)server {
    NSLog(@"exploring with rootitem id %@", rootItemObjectID);
    NSMutableArray *mediaItems = [[NSMutableArray alloc] init];
    for (MediaServer1BasicObject *item in [self mediaItemsForDirectory:rootItemObjectID onServer:server]) {
        if ([item isContainer]) {
            NSLog(@"exploring container %@", item.title);
            NSArray *items =[self exploreMediaDirectoryRecursively:[item objectID] onServer:server];
//            NSArray *items = [self mediaItemsForDirectory:[item objectID] onServer:server];
            NSLog(@"found %d items in %@ directory", [items count], item.title);
            [mediaItems addObjectsFromArray:items];
        } else {
            NSLog(@"adding media item %@", item.title);
            [mediaItems addObject:item];
        }
    }
    NSLog(@"going to return %d", [mediaItems count]);
    return [mediaItems copy];
}

- (NSArray *)mediaItemsForDirectory:(NSString *)rootItemObjectID onServer:(MediaServer1Device *)server {
    NSLog(@"retreiving media items for object id %@", rootItemObjectID);
    //pass by reference strings to read output
    NSMutableString *outResult = [[NSMutableString alloc] init];
    NSMutableString *outNumberReturned = [[NSMutableString alloc] init];
    NSMutableString *outTotalMatches = [[NSMutableString alloc] init];
    NSMutableString *outUpdateID = [[NSMutableString alloc] init];
    
    
    [[server contentDirectory] BrowseWithObjectID:rootItemObjectID
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
    NSMutableArray *mediaItems = [[NSMutableArray alloc] init];
    MediaServerBasicObjectParser *parser = [[MediaServerBasicObjectParser alloc] initWithMediaObjectArray:mediaItems];
    [parser parseFromData:didl];
    
    
    NSLog(@"returning %d mediaItems for directory %@", [mediaItems count], rootItemObjectID);
    return [mediaItems copy];
}


@end
