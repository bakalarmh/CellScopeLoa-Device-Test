//
//  DeviceManagerViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"

@interface DeviceManagerViewController : UITableViewController

@property (weak, nonatomic) BLEManager* bleManager;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
