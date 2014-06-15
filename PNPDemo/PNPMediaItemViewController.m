//
//  PNPMediaItemViewController.m
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "PNPMediaItemViewController.h"
#import "PNPMediaDeviceLibrary.h"

@interface PNPMediaItemViewController ()
@end

@implementation PNPMediaItemViewController
- (instancetype)initWithMediaItem:(MediaServer1BasicObject *)mediaItem {
    self = [super init];
    if (self) {
        self.mediaItem = mediaItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [playButton setTitle:@"PLAY" forState:UIControlStateNormal];
    playButton.frame = CGRectMake(20, 60, 300, 300);
    playButton.titleLabel.text = @"Play!";
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:playButton];
    
    UILabel *trackTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
    trackTitle.text = self.mediaItem.title;
    [self.view addSubview:trackTitle];
}


- (void)play {
    if ([[PNPMediaDeviceLibrary sharedLibrary] sonosPlayer]) {
        NSLog(@"have the sonos; can play");
        NSLog(@"lets play sampel track: %@", [self.mediaItem propertiesString]);
        [[PNPMediaDeviceLibrary sharedLibrary] playTrack:self.mediaItem];
    } else {
        NSLog(@"havent loaded sonos player; can't play");
    }
}

@end
