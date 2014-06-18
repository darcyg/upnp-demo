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
        //handle stream??
        NSLog(@"trying to play media stream");
        NSLog(@"media stream uri %@", mediaItem.uri);
        NSLog(@"%d", [[self sonosPlayer].avTransport SetAVTransportURIWithInstanceID:@"0"
                                                             CurrentURI:mediaItem.uri
                                                     CurrentURIMetaData:@""]);
        
    } else {
        [[self sonosPlayer].playList.playList removeAllObjects];
        [[self sonosPlayer].playList.playList addObject:track];
        [[self sonosPlayer] playWithMedia:track];
    }
}

-(void)UPnPDBWillUpdate:(UPnPDB*)sender{ NSLog(@"will update"); }

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    NSLog(@"looking for sonos player");
    self.privateDevices = [[[[UPnPManager GetInstance] DB] rootDevices] mutableCopy];
}

- (NSArray *)mediaDevices {
    return [self.privateDevices copy];
}

- (MediaRenderer1Device *)sonosPlayer {
    MediaRenderer1Device *sonosPlayer;
    for (BasicUPnPDevice *device in self.mediaDevices) {
        if ([device.friendlyName rangeOfString:@"Sonos PLAY:5 Media Renderer"].location != NSNotFound) {
            NSLog(@"found media renderer");
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

@end
