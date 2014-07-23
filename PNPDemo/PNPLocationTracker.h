//
//  PNPLocationTracker.h
//  PNPDemo
//
//  Created by Horace Williams on 7/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PNPLocationTracker : NSObject <CLLocationManagerDelegate>
- (void)registerForLocationNotifications;
- (CLLocationCoordinate2D)savedHomeLocation;
@end
