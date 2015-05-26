//
//  CaptureViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "CaptureViewController.h"
#import "constants.h"
#import "Video.h"
#import "CameraDispatcher.h"
#import "FrameBuffer.h"

@interface CaptureViewController () {
    NSInteger maxFields;
    NSInteger fieldIndex;
    NSInteger maxFrames;
    NSInteger frameIndex;
    FrameBuffer* frameBuffer;
}

@end

@implementation CaptureViewController

@synthesize camera;
@synthesize delegate;
@synthesize cameraPreviewView;
@synthesize focusSlider;
@synthesize focusModeControl;
@synthesize cameraButton;
@synthesize forwardButton;
@synthesize reverseButton;
@synthesize managedObjectContext;
@synthesize cslContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hard code the number of frames expected from the camera. Not happy about this
    maxFrames = 150;
    
    // Load the number of fields of view to acquire from user defaults
    maxFields = [[[NSUserDefaults standardUserDefaults] objectForKey:FieldsOfViewKey] integerValue];
    
    // Set up the camera
    camera = [[LLCamera alloc] init];
    [camera setPreviewLayer:cameraPreviewView.layer];
    
    // Start the camera session
    [camera startCamera];

    // Set up the delegates
    camera.focusDelegate = self;
    camera.captureDelegate = self;
    camera.frameProcessingDelegate = self;
    
    // Turn on the imaging LED and initialize the capillary position
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOn];
    }
    
    NSNumber* manualFocusDefault = [[NSUserDefaults standardUserDefaults] objectForKey:ManualFocusLensPositionKey];
    [camera setFocusLensPosition:manualFocusDefault];
    
    // Set the exposure and iso
    // NSValue* exposureValue = [[NSUserDefaults standardUserDefaults] objectForKey:ExposureKey];
    // NSNumber* isoValue = [[NSUserDefaults standardUserDefaults] objectForKey:ISOKey];

    // Hard coded exposure and iso. I am not happy with this.
    CMTime exposure = CMTimeMake(1, 256);
    [camera setExposureMinISO:exposure];
    
    // Launch the self test
    if (cslContext.capillaryIndex.intValue == 0) {
        [self precaptureDeviceTest];
        cameraButton.enabled = NO;
    }
    
    // Set up UI
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
    focusSlider.transform = trans;
    focusSlider.enabled = YES;
    focusSlider.alpha = 1.0;
    
    // Set the capture state
    fieldIndex = 0;
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

- (void)launchDataAcquisition
{
    if (fieldIndex < maxFields) {
        // Create a new frame buffer to store video frames
        frameBuffer = [[FrameBuffer alloc] initWithWidth:camera.width Height:camera.height Frames:maxFrames];
        NSURL* assetURL = [cslContext generateUniqueURLWithRecord:cslContext.activeTestRecord];
        [camera captureWithDuration:5.0 URL:assetURL];
        [UIView animateWithDuration:0.3 animations:^{
            cameraButton.enabled = NO;
        }];
    }
    else {
        NSLog(@"Acquisition of %d fields of view complete", (int)maxFields);
        [delegate didCompleteCapillaryCapture];
        
        // Advance the capillary and delay for sync
        if (cslContext.loaDevice != nil) {
            [cslContext.loaDevice servoLoadPosition];
        }
        
        // Return to the test view controller
        // [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)precaptureDeviceTest
{
    // Test Servo motion
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice servoPartialAdvance:0.5];
    }
    int msdelay = 500;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, msdelay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        // Test Servo motion
        if (cslContext.loaDevice != nil) {
            [cslContext.loaDevice servoLoadPosition];
        }
        int msdelay = 1500;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, msdelay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            cameraButton.enabled = YES;
        });
    });
}

- (void)prepareNextDataAcquisition
{
    fieldIndex += 1;
    frameIndex = 0;
    
    if (fieldIndex < maxFields) {
        // Advance the capillary and delay for sync
        if (cslContext.loaDevice != nil) {
            [cslContext.loaDevice servoAdvance];
        }
    }
    
    int delay = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self launchDataAcquisition];
    });
}

- (void)captureDidFinishWithURL:(NSURL *)assetURL
{
    NSLog(@"Capture finished!");
    [delegate didCaptureVideoWithURL:assetURL frameBuffer:frameBuffer];
    // Prepare next acquisition
    [self prepareNextDataAcquisition];
}

- (void)didReceiveFrame:(CVBufferRef)frame
{
    [frameBuffer writeFrame:frame atIndex:[NSNumber numberWithLong:frameIndex]];
    frameIndex += 1;
}

- (void)didFinishRecordingFrames:(LLCamera*)sender
{
    
}

- (IBAction)cameraPressed:(id)sender
{
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        focusSlider.alpha = 0.0;
        focusModeControl.alpha = 0.0;
    }];
    [self launchDataAcquisition];
}

- (IBAction)forwardPressed:(id)sender
{
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice servoAdvance];
    }
}

- (IBAction)reversePressed:(id)sender
{
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice servoRetract];
    }
}

- (IBAction)focusSliderValueChanged:(id)sender {
    [camera setFocusLensPosition:[NSNumber numberWithFloat:focusSlider.value]];
}

- (IBAction)focusModeChanged:(id)sender {
    if (focusModeControl.selectedSegmentIndex == 0) {
        [camera setFocusLensPosition:[NSNumber numberWithFloat:focusSlider.value]];
        focusSlider.enabled = YES;
        // Fade the focusSlider in
        [UIView animateWithDuration:0.3 animations:^{
            focusSlider.alpha = 1.0;
        }];
    }
    else if (focusModeControl.selectedSegmentIndex == 1) {
        [camera setContinuousAutoFocusState];
        focusSlider.enabled = NO;
        // Fade the focusSlider out
        [UIView animateWithDuration:0.3 animations:^{
            focusSlider.alpha = 0.0;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop the capture session
    [camera stopCamera];
    
    // Turn off the imaging LED
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOff];
    }
    
    // Store the latest manual focus setting as default
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:focusSlider.value] forKey:ManualFocusLensPositionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)focusDidChange:(NSNumber*)focusLensPosition
{
    focusSlider.value = focusLensPosition.floatValue;
}

- (IBAction)seroOutPressed:(id)sender
{
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice servoLoadPosition];
    }
}

- (IBAction)servoInPressed:(id)sender
{
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice servoFarPostition];
    }
}
@end
