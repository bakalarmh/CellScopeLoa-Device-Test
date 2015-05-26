//
//  WhiteBalanceViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "WhiteBalanceViewController.h"
#import "constants.h"

@interface WhiteBalanceViewController ()

@end

@implementation WhiteBalanceViewController

@synthesize cameraPreviewView;
@synthesize lockBarButtonItem;
@synthesize camera;
@synthesize cslContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the camera
    camera = [[LLCamera alloc] init];
    [camera setPreviewLayer:cameraPreviewView.layer];
    [camera startCamera];
    
    // Turn on the imaging LED
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOn];
    }
    
    [camera setContinuousWhiteBalanceState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop the capture session
    [camera stopCamera];
    camera = nil;
    
    // Turn off the imaging LED
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOff];
    }
    
    // Store the latest manual focus setting as default
    AVCaptureWhiteBalanceGains gains = [camera getCurrentWhiteBalanceGains];
    
    NSLog(@"%f %f %f", gains.redGain, gains.greenGain, gains.blueGain);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:gains.redGain] forKey:RedGainKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:gains.blueGain] forKey:BlueGainKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:gains.greenGain] forKey:GreenGainKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)lockButtonPressed:(id)sender {
    if ([lockBarButtonItem.title isEqualToString:@"Lock"]) {
        lockBarButtonItem.title = @"Unlock";
        [camera setLockedWhiteBalanceState];
    }
    else if([lockBarButtonItem.title isEqualToString:@"Unlock"]) {
        lockBarButtonItem.title = @"Lock";
        [camera setContinuousWhiteBalanceState];
    }
}

@end
