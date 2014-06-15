//
//  PNPMediaDirectoryLookup.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPMediaDirectoryLookup.h"
#import "MediaServer1Device.h"
#import "MediaServerBasicObjectParser.h"

@interface PNPMediaDirectoryLookup ()
@property (nonatomic, strong) BasicUPnPDevice *mediaDevice;
@property (nonatomic, strong) NSString *rootDirectoryName;
@end

@implementation PNPMediaDirectoryLookup
- (instancetype)initWithMediaDevice:(BasicUPnPDevice *)device rootDirectoryIdentifier:(NSString *)dirName {
    self = [super init];
    if (self) {
        self.rootDirectoryName = dirName;
        self.mediaDevice = device;
    }
    return self;
}

- (NSArray *)mediaItems {
    MediaServer1Device *mediaServer = (MediaServer1Device *)self.mediaDevice;
    if ([mediaServer respondsToSelector:@selector(contentDirectory)]) {
        return [self mediaItemsForDirectory:self.rootDirectoryName onServer:mediaServer];
    } else {
        NSLog(@"cant read media items from device: %@", self.mediaDevice.friendlyName);
        return @[];
    }
}

- (NSArray *)mediaItemsForDirectory:(NSString *)rootItemObjectID onServer:(MediaServer1Device *)server {
    NSLog(@"retreiving media items for object id %@", rootItemObjectID);
    NSMutableString *outResult = [[NSMutableString alloc] init];
    NSMutableString *outNumberReturned = [[NSMutableString alloc] init];
    NSMutableString *outTotalMatches = [[NSMutableString alloc] init];
    NSMutableString *outUpdateID = [[NSMutableString alloc] init];
    
    NSLog(@"server %@ content dir is %@", server.friendlyName, server.contentDirectory);
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

@end
