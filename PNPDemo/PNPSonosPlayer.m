//
//  PNPSonosPlayer.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPSonosPlayer.h"
#import "MediaRenderer1Device.h"
#import "MediaServer1BasicObject.h"
#import "PNPMediaDeviceLibrary.h"

@interface PNPSonosPlayer ()
@property (nonatomic, strong) MediaRenderer1Device *sonosMediaPlayer;
@end

@implementation PNPSonosPlayer

+ (instancetype)sharedPlayer {
    static PNPSonosPlayer *sharedPlayer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedPlayer) {
            sharedPlayer = [[self alloc] init];
        }
    });
    return sharedPlayer;
}

- (void)playTrack:(MediaServer1BasicObject *)track {
    
}
//
//- (MediaRenderer1Device *) sonosMediaPlayer {
//    if (!_sonosMediaPlayer) {
//        _sonosMediaPlayer =
//    }
//    retu
//    
//}

@end
