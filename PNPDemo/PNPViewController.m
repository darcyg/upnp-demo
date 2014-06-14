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

//NSString *objectID;
//NSString *parentID;
//NSString *objectClass;
//NSString *title;
//NSString *albumArt;
//
//BOOL isContainer;


-(void)UPnPDBUpdated:(UPnPDB*)sender{
    for (BasicUPnPDevice *device in self.mDevices) {
        
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaRenderer:1"]){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Renderer"].location != NSNotFound) {
                MediaRenderer1Device *mediaRenderer = (MediaRenderer1Device *)device;
                NSLog(@"SONOS MEDIA SERVER is %@", mediaRenderer.friendlyName);
                NSLog(@"mediaPlayList is %@", mediaRenderer.playList.playList);
                NSLog(@"lets play sampel track: %@", [[self sampleTrack] propertiesString]);
                [mediaRenderer playWithMedia:[self sampleTrack]];
//                SoapActionsAVTransport1 *avTransport =  (SoapActionsAVTransport1 *)[device getServiceForType:@"urn:schemas-upnp-org:service:AVTransport:1"].soap;
//                [(SoapActionsAVTransport1 *)avTransport.soap PlayWithInstanceID:@"0" Speed:@"1"];
//                NSMutableDictionary *services = [device getServices];
//                for(id key in services) {
//                    BasicUPnPService *service = [services objectForKey:key];
//                    if ([self.processedServices containsObject:service]) {
//                        continue;
//                    }

//                    [service process];
//                    [self.processedServices addObject:service];
//                }

            }
        }
        
        //THIS IS HOW U FIND SONOS MEDIA LIBRARY
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"] && NO){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Server"].location != NSNotFound) {
                NSLog(@"*************************searchfor sonos media");
                MediaServer1Device *sonosMediaServer = (MediaServer1Device *)device;
                NSLog(@"media items count %d", [[self exploreMediaDirectoryRecursively:@"0" onServer:sonosMediaServer] count]);
            }
        }

        
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:ZonePlayer:1"]){
            BasicUPnPDevice *server = (BasicUPnPDevice *)device;
            NSLog(@"server friendly name is %@", server.friendlyName);
            
            
            BasicUPnPService *musicService;
            for (BasicUPnPService *service in self.processedServices) {
                if ([service.serviceType isEqualToString:@"urn:schemas-upnp-org:service:MusicServices:1"]) {
                    musicService = service;
                }
            }
            
            NSLog(@"music service %@", musicService);
        }
    }
}

- (NSDictionary *)mediaInfoForConnection:(SoapActionsAVTransport1 *)connection {
    NSMutableString *tracks = [[NSMutableString alloc] init];
    NSMutableString *mediaDuration = [[NSMutableString alloc] init];
    NSMutableString *currentMediaURI = [[NSMutableString alloc] init];
    NSMutableString *currentMediaMetaData = [[NSMutableString alloc] init];
    NSMutableString *nextMediaURI = [[NSMutableString alloc] init];
    NSMutableString *nextMediaMetadata = [[NSMutableString alloc] init];
    NSMutableString *playMedium = [[NSMutableString alloc] init];
    NSMutableString *recordMedium = [[NSMutableString alloc] init];
    NSMutableString *writeStatus = [[NSMutableString alloc] init];
    
    [connection GetMediaInfoWithInstanceID:@"0"
                               OutNrTracks:tracks
                          OutMediaDuration:mediaDuration
                             OutCurrentURI:currentMediaURI
                     OutCurrentURIMetaData:currentMediaMetaData
                                OutNextURI:nextMediaURI
                        OutNextURIMetaData:nextMediaMetadata
                             OutPlayMedium:playMedium
                           OutRecordMedium:recordMedium
                            OutWriteStatus:writeStatus];
    
    return @{@"tracks": tracks,
             @"mediaDuration":mediaDuration,
             @"currentMediaURI":currentMediaURI,
             @"currentMediaMetaData":currentMediaMetaData,
             @"nextMediaURI":nextMediaURI,
             @"nextMediaMetaData":nextMediaMetadata,
             @"playMedium":playMedium,
             @"recordMedium":recordMedium,
             @"writeStatus":writeStatus};
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
            NSLog(@"media item %@", [item propertiesString]);
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

- (MediaServer1BasicObject *)sampleTrack {
    
//    2014-06-14 17:51:12.298 PNPDemo[39090:3a03] media item objectID: S://JCS-PC/Music/slsk/GOOD%20Music%20-%20Cruel%20Summer%20(2012)%20%5bV0%5d/09%20The%20One.mp3, parentID: A:ARTIST/2%20Chainz,%20Big%20Sean,%20Kanye%20West%20%26%20Marsha%20Ambrosius/, title: The One, objectClass: (null), isContainer: 0, albumArt: /getaa?u=x-file-cifs%3a%2f%2fJCS-PC%2fMusic%2fslsk%2fGOOD%2520Music%2520-%2520Cruel%2520Summer%2520(2012)%2520%255bV0%255d%2f09%2520The%2520One.mp3&v=18
    MediaServer1BasicObject *track = [[MediaServer1BasicObject alloc] init];
    track.title = @"The One";
    track.isContainer = NO;
    track.albumArt = @"/getaa?u=x-file-cifs%3a%2f%2fJCS-PC%2fMusic%2fslsk%2fGOOD%2520Music%2520-%2520Cruel%2520Summer%2520(2012)%2520%255bV0%255d%2f09%2520The%2520One.mp3&v=18";
    track.objectID = @"S://JCS-PC/Music/slsk/GOOD%20Music%20-%20Cruel%20Summer%20(2012)%20%5bV0%5d/09%20The%20One.mp3";
    track.parentID = @"A:ARTIST/2%20Chainz,%20Big%20Sean,%20Kanye%20West%20%26%20Marsha%20Ambrosius/";
    return track;
}


@end
