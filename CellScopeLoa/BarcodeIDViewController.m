//
//  igViewController.m
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BarcodeIDViewController.h"
#import "ManualIDViewController.h"
#import "TestViewController.h"

@interface BarcodeIDViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *output;
    AVCaptureVideoPreviewLayer *prevLayer;
    
    UIView *highlightView;
    
    NSString* codeText;
    BOOL codeFound;
    BOOL codeLocked;
    BOOL codeHolding;
}
@end

@implementation BarcodeIDViewController

@synthesize managedObjectContext;
@synthesize cslContext;
@synthesize recaptureID;

// UI Objects
@synthesize barcodeLabel;
@synthesize textEntryButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set up UI
    [self.navigationController.toolbar setHidden:YES];
    barcodeLabel.alpha = 0.0;
    self.textEntryButton.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL useFrontFacing = YES;
    
    // Set up barcode reader state
    codeText = @"";
    codeFound = NO;
    codeLocked = NO;
    
    highlightView = [[UIView alloc] init];
    highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    highlightView.layer.borderWidth = 3;
    [self.view addSubview:highlightView];
    
    session = [[AVCaptureSession alloc] init];
    
    if (useFrontFacing) {
        device = [self frontCamera];
    }
    else {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    NSError *error = nil;
    
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prevLayer.frame = self.view.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:prevLayer];
    
    [session startRunning];
    self.view.alpha = 0.0;
    
    // Fade the preview layer in
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
        self.textEntryButton.alpha = 1.0;
    }];
    
    [self.view bringSubviewToFront:highlightView];
    [self.view bringSubviewToFront:barcodeLabel];
    [self.view bringSubviewToFront:textEntryButton];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!codeLocked) {
        CGRect highlightViewRect = CGRectZero;
        AVMetadataMachineReadableCodeObject *barCodeObject;
        NSString *detectionString = nil;
        NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                                  AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                                  AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
        
        for (AVMetadataObject *metadata in metadataObjects) {
            for (NSString *type in barCodeTypes) {
                if ([metadata.type isEqualToString:type])
                {
                    barCodeObject = (AVMetadataMachineReadableCodeObject *)[prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                    highlightViewRect = barCodeObject.bounds;
                    detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                    break;
                }
            }
            
            if (detectionString != nil)
            {
                barcodeLabel.text = detectionString;
                barcodeLabel.alpha = 1.0;
                [self launchCodeLockTimer];
                break;
            }
            else {
                barcodeLabel.text = @"(none)";
            }
        }
        
        highlightView.frame = highlightViewRect;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self.navigationController.toolbar setHidden:NO];
    
    if ([segue.identifier isEqualToString:@"ManualID"]) {
        [self stopCaptureSession];
        ManualIDViewController* vc = (ManualIDViewController*)segue.destinationViewController;
        vc.managedObjectContext = managedObjectContext;
        vc.cslContext = cslContext;
        vc.recaptureID = recaptureID;
    }
    else if([segue.identifier isEqualToString:@"StartTest"]) {
        TestViewController* vc = (TestViewController*)segue.destinationViewController;
        vc.managedObjectContext = managedObjectContext;
        vc.cslContext = cslContext;
        vc.patientNIHID = codeText;
        if (recaptureID == NO) {
            vc.newTest = YES;
        }
        else {
            // Pass
        }
        
    }
}

// Unwind segue for changing a patient ID. Returns from the test screen, could be during an active test.
- (IBAction)unwindToBarcodeID:(UIStoryboardSegue *)unwindSegue
{
    // Diable returning to the home screen from this - only for changing ID
    [self.navigationController.toolbar setHidden:YES];
    self.navigationItem.hidesBackButton = YES;
}

- (void)launchCodeLockTimer
{
    if (codeFound == NO) {
        // Disable the reader after 1.5 seconds
        float delay = 1.5;
        codeFound = YES;
        codeText = barcodeLabel.text;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([codeText isEqualToString:barcodeLabel.text]) {
                [self lockCode];
            }
            else {
                codeFound = NO;
            }
        });
    }
}

- (void)stopCaptureSession
{
    [session stopRunning];
    [prevLayer removeFromSuperlayer];
    prevLayer = nil;
    session = nil;
}

- (void)lockCode
{
    codeLocked = YES;
    [[prevLayer connection] setEnabled:NO];
    [self performSegueWithIdentifier:@"StartTest" sender:self];
}

- (AVCaptureDevice *)frontCamera
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *dev in devices) {
        if ([dev position] == AVCaptureDevicePositionFront) {
            return dev;
        }
    }
    return nil;
}

@end