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
@property (nonatomic) BOOL handledSonos;
@property (nonatomic, strong) NSMutableArray *processedServices;
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
    self.processedServices = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    for (BasicUPnPDevice *device in self.mDevices) {
        
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaRenderer:1"]){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Server"].location != NSNotFound) {
                NSLog(@"media renderer friendly name is %@", device.friendlyName);
            }
        }
        
        //THIS IS HOW U FIND SONOS MEDIA LIBRARY
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"]){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Server"].location != NSNotFound) {
                if (!self.handledSonos) {
                    NSLog(@"going to read conetnts from sonos server recursively");
                    MediaServer1Device *sonosMediaServer =  (MediaServer1Device *)device;
                    NSArray *results = [self exploreMediaDirectoryRecursively:@"0" onServer:sonosMediaServer];
                    NSLog(@"results count %d", [results count]);
                    self.handledSonos = YES;
                }
            }
        }

//        NSLog(@"urn is %@", device.urn);
//        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"]){
        
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:ZonePlayer:1"]){
//        if (YES) {
            BasicUPnPDevice *server = (BasicUPnPDevice *)device;
            NSLog(@"server friendly name is %@", server.friendlyName);
            NSMutableDictionary *services = [server getServices] ;
            
            for(id key in services) {
                BasicUPnPService *service = [services objectForKey:key];
                if ([self.processedServices containsObject:service]) {
                    continue;
                }

                [service process];
                [self.processedServices addObject:service];
            }
            
            BasicUPnPService *musicService;
            for (BasicUPnPService *service in self.processedServices) {
                if ([service.serviceType isEqualToString:@"urn:schemas-upnp-org:service:MusicServices:1"]) {
                    musicService = service;
                }
            }
            
            NSLog(@"music service %@", musicService);

            
            //        2014-06-14 15:57:27.456 PNPDemo[36850:4403] BasicUPnPService - initWithSSDPDevice - urn:schemas-upnp-org:service:MusicServices:1


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
