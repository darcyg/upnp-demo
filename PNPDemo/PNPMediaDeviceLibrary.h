//
//  PNPMediaDeviceLibrary.h
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaRenderer1Device.h"

@interface PNPMediaDeviceLibrary : NSObject
@property (readonly, copy) NSArray *mediaDevices;
+ (PNPMediaDeviceLibrary *) sharedLibrary;
- (void)scanForMediaDevices;
- (MediaRenderer1Device *)sonosPlayer;
- (void)playTrack:(MediaServer1BasicObject *)track;
@end
