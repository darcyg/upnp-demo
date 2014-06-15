//
//  PNPMediaDirectoryTableViewController.h
//  PNPDemo
//
//  Created by Horace Williams on 6/15/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicUPnPDevice.h"

@interface PNPMediaDirectoryTableViewController : UITableViewController
- (instancetype)initWithMediaDevice:(BasicUPnPDevice *)device rootDirectoryIdentifier:(NSString *)dirName;
@end
