//
//  CaptureViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLCamera.h"
#import "CSLContext.h"
#import "CaptureCamera.h"

@protocol CaptureViewControllerDelegate
- (void)didCaptureVideoWithURL:(NSURL*)assetURL frameBuffer:(FrameBuffer*)buffer;
- (void)didCompleteCapillaryCapture;
@end

@interface CaptureViewController : UIViewController <FocusDelegate, CaptureDelegate, FrameProcessingDelegate>

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;

@property (strong, nonatomic) LLCamera* camera;
@property (strong, nonatomic) id<CaptureViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *reverseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UISlider *focusSlider;
@property (weak, nonatomic) IBOutlet UIButton *autofocusButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *focusModeControl;
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;


- (IBAction)focusSliderValueChanged:(id)sender;
- (IBAction)focusModeChanged:(id)sender;
- (IBAction)cameraPressed:(id)sender;
- (IBAction)forwardPressed:(id)sender;
- (IBAction)reversePressed:(id)sender;
- (IBAction)seroOutPressed:(id)sender;
- (IBAction)servoInPressed:(id)sender;

@end
