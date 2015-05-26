//
//  AugmentedMotionScopeViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/19/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "AugmentedMotionScopeViewController.h"
#import "constants.h"

@interface AugmentedMotionScopeViewController () {
    LLCamera* camera;
    CIImage* backgroundImage;
}

@end

@implementation AugmentedMotionScopeViewController

@synthesize cslContext;
@synthesize augmentedImageView;
@synthesize focusSlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the camera
    camera = [[LLCamera alloc] init];
    // [camera setPreviewLayer:cameraPreviewView.layer];
    
    // Start the camera session
    [camera startCamera];
    
    // Set up the delegates
    camera.cgProcessingDelegate = self;
    
    // Turn on the imaging LED and initialize the capillary position
    if (cslContext.loaDevice != nil) {
        [cslContext.loaDevice LEDOn];
    }
    
    // Set up the UI
    augmentedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
    focusSlider.transform = trans;
    focusSlider.enabled = YES;
    focusSlider.alpha = 1.0;
    
    NSNumber* manualFocusDefault = [[NSUserDefaults standardUserDefaults] objectForKey:ManualFocusLensPositionKey];
    [camera setFocusLensPosition:manualFocusDefault];
    camera.focusDelegate = self;

    // Set the exposure and iso
    // NSValue* exposureValue = [[NSUserDefaults standardUserDefaults] objectForKey:ExposureKey];
    // NSNumber* isoValue = [[NSUserDefaults standardUserDefaults] objectForKey:ISOKey];
    
    // Hard coded exposure and iso. I am not happy with this.
    [camera setAutoExposureContinuous];    
    [camera startSendingFrames];

}

- (void)didReceiveFrame:(CGImageRef)imageRef
{
    CIImage *inputImage = [CIImage imageWithCGImage:imageRef];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CIImage *grayscaleImage = [filter valueForKey:kCIOutputImageKey];
    
    if (backgroundImage != nil) {
        CIFilter *filter = [CIFilter filterWithName:@"CISubtractBlendMode"];
        [filter setValue:grayscaleImage forKey:kCIInputImageKey];
        [filter setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
        CIImage *differenceImage = [filter valueForKey:kCIOutputImageKey];
        
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
        [colorFilter setValue:differenceImage forKey:kCIInputImageKey];
        [colorFilter setValue:[CIColor colorWithRed:0.0 green:0.0 blue:0.0] forKey:@"inputColor0"];
        [colorFilter setValue:[CIColor colorWithRed:0.0 green:1.0 blue:0.0] forKey:@"inputColor1"];
        CIImage *colorImage = [colorFilter valueForKey:kCIOutputImageKey];
        
        CIFilter *augmentFilter = [CIFilter filterWithName:@"CIAdditionCompositing"];
        [augmentFilter setValue:colorImage forKey:kCIInputImageKey];
        [augmentFilter setValue:inputImage forKey:kCIInputBackgroundImageKey];
        
        // Create a CG-back UIImage
        CGImageRef cgOutputImage = [[CIContext contextWithOptions:nil] createCGImage:augmentFilter.outputImage fromRect:filter.outputImage.extent];
        UIImage* outputImage = [UIImage imageWithCGImage:cgOutputImage];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            augmentedImageView.image = outputImage;
            CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
            augmentedImageView.transform = trans;
            CGImageRelease(cgOutputImage);
        }];
    }
    backgroundImage = grayscaleImage;
}

- (IBAction)focusSliderValueChanged:(id)sender {
    [camera setFocusLensPosition:[NSNumber numberWithFloat:focusSlider.value]];
}

- (void)focusDidChange:(NSNumber*)focusLensPosition
{
    focusSlider.value = focusLensPosition.floatValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
