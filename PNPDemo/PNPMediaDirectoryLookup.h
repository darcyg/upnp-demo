//
//  PNPMediaDirectoryLookup.h
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicUPnPDevice.h"

@interface PNPMediaDirectoryLookup : NSObject
- (instancetype)initWithMediaDevice:(BasicUPnPDevice *)device rootDirectoryIdentifier:(NSString *)dirName;
- (NSArray *)mediaItems;
@end
