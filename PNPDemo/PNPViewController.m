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
@property (nonatomic) BOOL handledSonos;
@property (nonatomic, strong) MediaRenderer1Device *sonosMediaPlayer;
@property (weak, nonatomic) IBOutlet UILabel *loadedLabel;
@property (nonatomic, strong) MediaServer1Device *sonosMediaServer;
@end

@implementation PNPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self findMediaServers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"view will appear; devices are: %@ and %@", self.sonosMediaPlayer, self.sonosMediaServer);
}

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"upnp updated");
    for (BasicUPnPDevice *device in self.mDevices) {
        if (self.sonosMediaServer && self.sonosMediaPlayer) {
            NSLog(@"detected both sonos components; stopping");
            self.loadedLabel.text = @"loaded player, play away!";
            [[[UPnPManager GetInstance] DB] removeObserver:(UPnPDBObserver *)self];
            continue;
        }
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaRenderer:1"]){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Renderer"].location != NSNotFound) {
                NSLog(@"found media renderer");
                self.sonosMediaPlayer = (MediaRenderer1Device *)device;
            }
        }
        
        if([[device urn] isEqualToString:@"urn:schemas-upnp-org:device:MediaServer:1"]){
            if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Server"].location != NSNotFound) {
                NSLog(@"found media server");
                self.sonosMediaServer = (MediaServer1Device *)device;
            }
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
            MediaServer1ItemObject *track = (MediaServer1ItemObject *)item;
            NSLog(@"media item %@", [track propertiesString]);
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

- (MediaServer1BasicObject *)sampleItem {
    MediaServer1BasicObject *track = [[MediaServer1BasicObject alloc] init];
    track.title = @"The One";
    track.isContainer = NO;
    track.albumArt = @"/getaa?u=x-file-cifs%3a%2f%2fJCS-PC%2fMusic%2fslsk%2fGOOD%2520Music%2520-%2520Cruel%2520Summer%2520(2012)%2520%255bV0%255d%2f09%2520The%2520One.mp3&v=18";
    track.objectID = @"S://JCS-PC/Music/slsk/GOOD%20Music%20-%20Cruel%20Summer%20(2012)%20%5bV0%5d/09%20The%20One.mp3";
    track.parentID = @"A:ARTIST/2%20Chainz,%20Big%20Sean,%20Kanye%20West%20%26%20Marsha%20Ambrosius/";
    return track;
}

- (MediaServer1ItemObject *)sampleTrack {
    MediaServer1ItemObject *track = [[MediaServer1ItemObject alloc] init];
    track.objectID = @"S://JCS-PC/Music/slsk/Modest%20Mouse%20-%20Moon%20and%20Antarctica/Modest%20Mouse%20-%2012%20-%20I%20Came%20As%20a%20Rat.mp3";
    track.parentID = @"A:ARTIST/12%20modest%20mouse/";
    track.title = @"i came as a rat";
    track.isContainer = NO;
    track.albumArt = @"/getaa?u=x-file-cifs%3a%2f%2fJCS-PC%2fMusic%2fslsk%2fModest%2520Mouse%2520-%2520Moon%2520and%2520Antarctica%2fModest%2520Mouse%2520-%252012%2520-%2520I%2520Came%2520As%2520a%2520Rat.mp3&v=18";
    track.artist = @"modest mouse";
    track.album = @"moon and antartica";
    track.date = nil;
    track.genre = @"";
    track.uri = @"x-file-cifs://JCS-PC/Music/slsk/Modest%20Mouse%20-%20Moon%20and%20Antarctica/Modest%20Mouse%20-%2012%20-%20I%20Came%20As%20a%20Rat.mp3";
    track.protocolInfo = @" x-file-cifs:*:audio/mpeg:*";
    track.uriCollection = @{@"x-file-cifs:*:audio/mpeg:*":@"x-file-cifs://JCS-PC/Music/slsk/Modest%20Mouse%20-%20Moon%20and%20Antarctica/Modest%20Mouse%20-%2012%20-%20I%20Came%20As%20a%20Rat.mp3"};
    return track;
}

- (void)findMediaServers {
    NSLog(@"find media servers");
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    self.mDevices = [db rootDevices];
    [db addObserver:(UPnPDBObserver *)self];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
}

- (IBAction)play:(id)sender {
    if (self.sonosMediaPlayer) {
        [self.sonosMediaPlayer.playList.playList addObject:[self sampleTrack]];
        NSLog(@"lets play sampel track: %@", [[self sampleTrack] propertiesString]);
        [self.sonosMediaPlayer playWithMedia:[self sampleTrack]];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"sonos player not found"
                                   message:@"try again"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:nil] show];
    }

}

@end
