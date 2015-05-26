//
//  SettingsTableViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/11/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "ExposureISOViewController.h"
#import "WhiteBalanceViewController.h"
#import "constants.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

@synthesize cslContext;
@synthesize phoneIDField;
@synthesize deviceIDField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    phoneIDField.delegate = self;
    deviceIDField.delegate = self;

    phoneIDField.text = [[NSUserDefaults standardUserDefaults] objectForKey:SimplePhoneIDKey];;
    deviceIDField.text = [[NSUserDefaults standardUserDefaults] objectForKey:SimpleDeviceIDKey];;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ExposureISO"]) {
        ExposureISOViewController* vc = (ExposureISOViewController*)segue.destinationViewController;
        vc.cslContext = cslContext;
    }
    else if([segue.identifier isEqualToString:@"WhiteBalance"]) {
        WhiteBalanceViewController* vc = (WhiteBalanceViewController*)segue.destinationViewController;
        vc.cslContext = cslContext;
    }
}

- (BOOL)textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)phoneIDEdited:(id)sender {
    // Store the latest SimplePhoneID as default
    [[NSUserDefaults standardUserDefaults] setObject:phoneIDField.text forKey:SimplePhoneIDKey];
    [[NSUserDefaults standardUserDefaults] setObject:deviceIDField.text forKey:SimpleDeviceIDKey];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"WhiteBalance" sender:self];
        }
        else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"ExposureISO" sender:self];
        }
    }
}

@end
