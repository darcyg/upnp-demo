//
//  PNPSonosPlayer.h
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaServer1BasicObject.h"

@interface PNPSonosPlayer : NSObject
- (void)playTrack:(MediaServer1BasicObject *)track;
+ (instancetype)sharedPlayer;
@end
