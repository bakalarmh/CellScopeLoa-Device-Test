//
//  DevicesTableViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextBluetoothScanner.h"
#import "BLEManager.h"

@interface DeviceTableViewController : UITableViewController

@property (strong, nonatomic) TextBluetoothScanner* textBluetoothScanner;
@property (weak, nonatomic) BLEManager* bleManager;

- (IBAction)identifyBoard:(id)sender;

@end
