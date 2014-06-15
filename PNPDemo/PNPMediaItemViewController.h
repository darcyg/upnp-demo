//
//  PNPMediaItemViewController.h
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaServer1BasicObject.h"

@interface PNPMediaItemViewController : UIViewController
@property (nonatomic, strong) MediaServer1BasicObject *mediaItem;
- (instancetype) initWithMediaItem:(MediaServer1BasicObject *)mediaItem;
@end
