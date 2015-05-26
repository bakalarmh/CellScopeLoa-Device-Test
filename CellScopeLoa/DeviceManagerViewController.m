//
//  DeviceManagerViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "DeviceTableViewController.h"

@interface DeviceManagerViewController ()

@end

@implementation DeviceManagerViewController

@synthesize bleManager;
@synthesize deviceLabel;
@synthesize statusLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [bleManager seekDevices];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set up UI elements
    deviceLabel.text = bleManager.lastUUID;
    if (bleManager.connected) {
        statusLabel.text = @"Connected";
        statusLabel.textColor = [UIColor colorWithRed:0.0 green:0.8 blue:0 alpha:1]; /*#00CC00*/
    }
    else {
        statusLabel.text = @"Disconnected";
        statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:1]; /*#00CC00*/
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"DeviceTable"]) {
        DeviceTableViewController* vc = (DeviceTableViewController*)segue.destinationViewController;
        vc.bleManager = bleManager;
    }
}

@end
