//
//  ExposureISOViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "ExposureISOViewController.h"
#import "constants.h"

@interface ExposureISOViewController () {
    float scaleFactor;
    float exposure;
    float iso;
}

@end

@implementation ExposureISOViewController

@synthesize cameraPreviewView;
@synthesize exposureTextField;
@synthesize cslContext;
@synthesize ISOTextField;
@synthesize camera;
@synthesize isoSlider;
@synthesize exposureSlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ISO and exposure scaling factor for the sliders
    
    // Set up the camera
    camera = [[LLCamera alloc] init];
    [camera setPreviewLayer:cameraPreviewView.layer];
    [camera startCamera];
    
    // Turn on the imaging LED
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOn];
    }
    
    exposure = [[[NSUserDefaults standardUserDefaults] objectForKey:ExposureKey] floatValue];
    iso = [[[NSUserDefaults standardUserDefaults] objectForKey:ISOKey] floatValue];
    
    [camera setRelativeExposure:exposure];
    exposureSlider.value = exposure;
    exposureTextField.text = [NSString stringWithFormat:@"%f",exposure];

    [camera setRelativeISO:iso];
    isoSlider.value = iso;
    ISOTextField.text = [NSString stringWithFormat:@"%f",iso];
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
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:exposure] forKey:ExposureKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:iso] forKey:ISOKey];
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

- (IBAction)exposureSliderChanged:(id)sender {
    exposure = [(UISlider*)sender value];
    exposureTextField.text = [NSString stringWithFormat:@"%f",exposure];
    [camera setRelativeExposure:exposure];
}

- (IBAction)ISOSliderChanged:(id)sender {
    iso = [(UISlider*)sender value];
    ISOTextField.text = [NSString stringWithFormat:@"%.2f",iso];
    [camera setRelativeISO:iso];
}

@end
