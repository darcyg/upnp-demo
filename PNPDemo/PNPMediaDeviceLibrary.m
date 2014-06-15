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
    [[self sonosPlayer].playList.playList removeAllObjects];
    [[self sonosPlayer].playList.playList addObject:track];
    [[self sonosPlayer] playWithMedia:track];
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

@end
