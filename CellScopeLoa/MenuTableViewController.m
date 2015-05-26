//
//  MenuTableViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "MenuTableViewController.h"
#import "DeviceManagerViewController.h"
#import "CaptureViewController.h"
#import "SettingsPasswordViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

@synthesize managedObjectContext;
@synthesize cslContext;

// UI Objects
@synthesize MenuTableView;
@synthesize ToolbarStatusButton;
@synthesize connectionStatusItem;
@synthesize testButtonLabel;
@synthesize testButtonIcon;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Bluetooth manager lives here
    BLEManager* bleManager = [[BLEManager alloc] init];
    bleManager.delegate = self;
    cslContext.bleManager = bleManager;
    
    // Setup UI state of the connected indicator
    testButtonLabel.alpha = 0.2;
    testButtonIcon.alpha = 0.2;
    if (bleManager.connected) {
        connectionStatusItem.title = NSLocalizedString(@"Connected",nil);
        connectionStatusItem.tintColor = [UIColor colorWithRed:0.0 green:0.8 blue:0 alpha:1]; /*#00CC00*/
    }
    else {
        cslContext.loaDevice = nil;
        connectionStatusItem.title = NSLocalizedString(@"Disconnected",nil);
        connectionStatusItem.tintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:1]; /*#00CC00*/
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.toolbar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    if (indexPath.row == 0) {
        if ([cslContext deviceIsConnected]) {
            return indexPath;
        }
        else {
            return nil;
        }
    }
    // By default, allow row to be selected
    return indexPath;
}

#pragma mark - Bluetooth

// Seek devices when the board is powered on
- (void)bluetoothStateDidChange:(CBCentralManagerState)state
{
    if (state == CBCentralManagerStatePoweredOn) {
        [cslContext.bleManager seekDevices];
    }
}

- (void)didUpdateDevices
{
    BLEManager* manager = cslContext.bleManager;
    BOOL foundTrusted = NO;
    // Connect to trusted UUID if it is detected
    NSMutableArray* mDevices = manager.mDevices;
    for (int i=0; i< mDevices.count; i++) {
        if ([[mDevices objectAtIndex:i] isEqualToString:manager.lastUUID]) {
            [manager connectWithUUID:manager.lastUUID];
            foundTrusted = YES;
            break;
        }
    }
    if (!foundTrusted) {
        connectionStatusItem.title = NSLocalizedString(@"Disconnected",nil);
        connectionStatusItem.tintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:1]; /*#00CC00*/
    }
}

- (void)didConnect
{
    connectionStatusItem.title = NSLocalizedString(@"Connected",nil);
    connectionStatusItem.tintColor = [UIColor colorWithRed:0 green:0.8 blue:0 alpha:1]; /*#00CC00*/
    
    testButtonLabel.alpha = 1.0;
    testButtonIcon.alpha = 1.0;
    
    cslContext.loaDevice = [[BluetoothLoaDevice alloc] initWithBLEManager:cslContext.bleManager];
    [cslContext.loaDevice LEDOn];
    [cslContext.loaDevice servoLoadPosition];
    
    int delay = 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (cslContext.loaDevice != nil) {
            [cslContext.loaDevice LEDOff];
        }
    });
}

- (void)didDisconnect
{
    connectionStatusItem.title = NSLocalizedString(@"Disconnected",nil);
    connectionStatusItem.tintColor = [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:1]; /*#FF0000*/
    
    cslContext.loaDevice = nil;
    
    testButtonLabel.alpha = 0.2;
    testButtonIcon.alpha = 0.2;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Test"]) {
        if ([cslContext deviceIsConnected]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DeviceTest"]) {
        CaptureViewController* vc = (CaptureViewController*)segue.destinationViewController;
        vc.managedObjectContext = managedObjectContext;
        vc.cslContext = cslContext;
    }
    else if([segue.identifier isEqualToString:@"Settings"]) {
        SettingsPasswordViewController* vc = (SettingsPasswordViewController*)segue.destinationViewController;
        vc.cslContext = cslContext;
    }
    else if([segue.identifier isEqualToString:@"Devices"]) {
        DeviceManagerViewController* vc = (DeviceManagerViewController*)segue.destinationViewController;
        vc.bleManager = cslContext.bleManager;
    }
}

// Unwind segue for changing a patient ID. Returns from the test screen, could be during an active test.
- (IBAction)unwindToMainMenu:(UIStoryboardSegue *)unwindSegue
{
    // Diable returning to the home screen from this - only for changing ID
    [self.navigationController.toolbar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
}

// Unwind segue for return from valid test results
- (IBAction)unwindToMainMenuValidTest:(UIStoryboardSegue *)unwindSegue
{
    // Diable returning to the home screen from this - only for changing ID
    [self.navigationController.toolbar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
}

// Unwind segue for return from valid test results
- (IBAction)unwindToMainMenuInvalidTest:(UIStoryboardSegue *)unwindSegue
{
    // Diable returning to the home screen from this - only for changing ID
    [self.navigationController.toolbar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (IBAction)connectionStatusPressed:(id)sender {
    BLEManager* manager = cslContext.bleManager;
    if (!manager.connected) {
        connectionStatusItem.title = NSLocalizedString(@"Searching",nil);
        connectionStatusItem.tintColor = [UIColor colorWithRed:1.0 green:0.8 blue:0 alpha:1]; /*#00CC00*/
        [manager seekDevices];
    }
}

@end
