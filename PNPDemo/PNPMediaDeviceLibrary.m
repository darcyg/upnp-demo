//
//  PNPMediaDeviceLibrary.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPMediaDeviceLibrary.h"
#import "UPnPDB.h"
#import "UPnPManager.h"
#import "PNPStaticShit.h"

@interface PNPMediaDeviceLibrary () <UPnPDBObserver>
@property (nonatomic, strong) NSMutableArray *privateDevices;
@end

@implementation PNPMediaDeviceLibrary
+ (instancetype)sharedLibrary {
    static PNPMediaDeviceLibrary *sharedLibrary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedLibrary) {
            sharedLibrary = [[self alloc] init];
        }
    });
    return sharedLibrary;
}

- (instancetype)init {
    self =  [super init];
    if (self) {
        _privateDevices = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)scanForMediaDevices {
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    [db addObserver:(UPnPDBObserver *)self];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
}

- (void)playTrack:(MediaServer1BasicObject *)track {
    MediaServer1ItemObject *mediaItem = (MediaServer1ItemObject *)track;
    if (([mediaItem.protocolInfo rangeOfString:@"sonos.com"].location != NSNotFound) || ([mediaItem.protocolInfo rangeOfString:@"x-rincon"].location != NSNotFound)) {
        // prepare content server for connection
        // get instance id
        // prepare renderer for connection (using instance id)
        // set av URI for server
        // set AV URI for renderer
        
        NSLog(@"media stream uri %@", mediaItem.uri);
        NSLog(@"%d", [[self sonosMediaServer].avTransport SetAVTransportURIWithInstanceID:@"0"
                                                             CurrentURI:mediaItem.uri
                                                     CurrentURIMetaData:@""]);
        
        NSMutableString *outConnectionID = [[NSMutableString alloc] init];
        NSMutableString *outAvTransportID = [[NSMutableString alloc] init];
        NSMutableString *outRcsID = [[NSMutableString alloc] init];
        
        int something = [[self sonosMediaServer].connectionManager PrepareForConnectionWithRemoteProtocolInfo:mediaItem.protocolInfo
                                                                        PeerConnectionManager:@"0"
                                                                             PeerConnectionID:@"0"
                                                                                    Direction:@"Output"
                                                                              OutConnectionID:outConnectionID
                                                                             OutAVTransportID:outAvTransportID
                                                                                     OutRcsID:outRcsID];
        
        NSLog(@"connected: %d", something);
        
        [[self sonosPlayer].connectionManager PrepareForConnectionWithRemoteProtocolInfo:mediaItem.protocolInfo
                                                                   PeerConnectionManager:@"0"
                                                                        PeerConnectionID:@"0"
                                                                               Direction:@"Input"
                                                                         OutConnectionID:outConnectionID
                                                                        OutAVTransportID:outAvTransportID
                                                                                OutRcsID:outRcsID];

        
        
        
//        NSMutableString *protocolInfo = [[NSMutableString alloc] init];
//        NSMutableString *protocolSink = [[NSMutableString alloc] init];
//        [[[self sonosMediaServer] connectionManager] GetProtocolInfoWithOutSource:protocolInfo OutSink:protocolSink];
//        NSLog(@"media server protocol info %@, sink %@", protocolInfo, protocolSink);
//        [[[self sonosPlayer] connectionManager] GetProtocolInfoWithOutSource:protocolInfo OutSink:protocolSink];
//        NSLog(@"media renderer protocol info %@, sink %@", protocolInfo, protocolSink);


        NSLog(@"server info %@", [self mediaServerInfo]);
        [[[self sonosMediaServer] avTransport] PlayWithInstanceID:@"0" Speed:@"1"];

        
    } else {
        [[self sonosPlayer].playList.playList removeAllObjects];
        [[self sonosPlayer].playList.playList addObject:track];
        [[self sonosPlayer] playWithMedia:track];
    }
}

-(void)UPnPDBWillUpdate:(UPnPDB*)sender{ }

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    self.privateDevices = [[[[UPnPManager GetInstance] DB] rootDevices] mutableCopy];
}

- (NSArray *)mediaDevices {
    return [self.privateDevices copy];
}

- (MediaRenderer1Device *)sonosPlayer {
    MediaRenderer1Device *sonosPlayer;
    for (BasicUPnPDevice *device in self.mediaDevices) {
        if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Renderer"].location != NSNotFound) {
            sonosPlayer = (MediaRenderer1Device *)device;
        }
    }
    return sonosPlayer;
}

- (MediaServer1Device *)sonosMediaServer {
    MediaServer1Device *sonosMediaServer;
    for (BasicUPnPDevice *device in self.mediaDevices) {
        if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Server"].location != NSNotFound) {
            sonosMediaServer = (MediaServer1Device *)device;
        }
    }
    return sonosMediaServer;
}

- (NSString *)mediaServerInfo {
//    -(int)GetMediaInfoWithInstanceID:(NSString*)instanceid OutNrTracks:(NSMutableString*)nrtracks OutMediaDuration:(NSMutableString*)mediaduration OutCurrentURI:(NSMutableString*)currenturi OutCurrentURIMetaData:(NSMutableString*)currenturimetadata OutNextURI:(NSMutableString*)nexturi OutNextURIMetaData:(NSMutableString*)nexturimetadata OutPlayMedium:(NSMutableString*)playmedium OutRecordMedium:(NSMutableString*)recordmedium OutWriteStatus:(NSMutableString*)writestatus;
    NSMutableString *outTrack = [[NSMutableString alloc] init];
    NSMutableString *outDuration = [[NSMutableString alloc] init];
    NSMutableString *outURI = [[NSMutableString alloc] init];
    NSMutableString *outURIMetaData = [[NSMutableString alloc] init];
    NSMutableString *outPlayMedium = [[NSMutableString alloc] init];
    NSMutableString *outNextURI = [[NSMutableString alloc] init];
    NSMutableString *outNextURIMetaData = [[NSMutableString alloc] init];
    NSMutableString *outRecordMedium = [[NSMutableString alloc] init];
    NSMutableString *outWriteStatus = [[NSMutableString alloc] init];
    
    [[[self sonosMediaServer] avTransport] GetMediaInfoWithInstanceID:@"0" OutNrTracks:outTrack OutMediaDuration:outDuration OutCurrentURI:outURI OutCurrentURIMetaData:outURIMetaData OutNextURI:outNextURI OutNextURIMetaData:outNextURIMetaData OutPlayMedium:outPlayMedium OutRecordMedium:outRecordMedium OutWriteStatus:outWriteStatus];
    
    return [NSString stringWithFormat:@"track: %@, outURI: %@, outURIMetaData: %@", outTrack, outURI, outURIMetaData];
}

- (void)playDrake {
    if ([self sonosPlayer]) {
        NSLog(@"tryna play drake");
        [[self sonosPlayer].avTransport SetAVTransportURIWithInstanceID:@"0"
                                                             CurrentURI:[PNPStaticShit drakeUrl]
                                                     CurrentURIMetaData:@""];
        [[self sonosPlayer].avTransport PlayWithInstanceID:@"0" Speed:@"1"];
    } else {
        NSLog(@"dont have sonos cant play");
//        [self findMediaServers];
    }
}

@end

//algo sketch
//set home location
//register for home location -- leaving region
    // leave region: register for home location: return to region
    // return to region: register for reachability
        //reachability: connected to wifi
            // start searching for servers
            // found server; play media
