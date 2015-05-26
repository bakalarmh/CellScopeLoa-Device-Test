//
//  CaptureCamera.m
//  CellScopeLoa2
//
//  Created by Matthew Bakalar on 1/11/14.
//  Copyright (c) 2014 Matthew Bakalar. All rights reserved.
//

#import "CaptureCamera.h"

@implementation CaptureCamera {
    dispatch_queue_t videoQueue; // Queue for processing frames and writing video
    CMTime videoTime;            // Time for video frames
    float captureProgress;
    BOOL writingFrames;
}

// Delegates
@synthesize recordingDelegate;
@synthesize processingDelegate;
@synthesize progressDelegate;
@synthesize focusDelegate;

// AVFoundation camera properties
@synthesize assetWriter;
@synthesize assetWriterInput;
@synthesize pixelBufferAdaptor;
@synthesize session;
@synthesize videoPreviewLayer;
@synthesize videoHDOutput;
@synthesize videoPreviewOutput;
@synthesize input;
@synthesize device;

// Camera state properties
@synthesize temporaryOutputPath;
@synthesize width;
@synthesize height;

- (id)initWithWidth:(NSInteger)frameWidth Height:(NSInteger)frameHeight
{
    self = [super init];
    
    self.width = [NSNumber numberWithInteger:frameWidth];
    self.height = [NSNumber numberWithInteger:frameHeight];
    
    // Initialize the state of the camera
    writingFrames = NO;
    videoQueue = dispatch_queue_create("VideoQueue", DISPATCH_QUEUE_SERIAL);
    
    // Setup the AV foundation capture session
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([self.device isFocusModeSupported:AVCaptureFocusModeLocked] ) {
        [self.device lockForConfiguration:nil];
        [self.device setFocusMode:AVCaptureFocusModeLocked];
        [self.device unlockForConfiguration];
    }
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Setup movie output
    NSDictionary *outputSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithLong:frameWidth], AVVideoWidthKey,
     [NSNumber numberWithLong:frameHeight], AVVideoHeightKey,
     AVVideoCodecH264, AVVideoCodecKey,
     nil];
	self.assetWriterInput = [AVAssetWriterInput
                             assetWriterInputWithMediaType:AVMediaTypeVideo
                             outputSettings:outputSettings];
    
    // Setup pixel buffer adaptor
    pixelBufferAdaptor =
    [[AVAssetWriterInputPixelBufferAdaptor alloc]
     initWithAssetWriterInput:assetWriterInput
     sourcePixelBufferAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
      kCVPixelBufferPixelFormatTypeKey,
      nil]];
    
    assetWriterInput.expectsMediaDataInRealTime = YES;
    
    // Add session input and output
    [self.session addInput:self.input];
    
    // Setup live processing output
    AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];
    dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [dataOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    if ([self.session canAddOutput:dataOutput]) {
        [self.session addOutput:dataOutput];
    }
    
    AVCaptureConnection *captureConnection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported]) {
        [captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    
    // Setup frame buffer
    [dataOutput setSampleBufferDelegate:self queue:videoQueue];
    
    return self;
}

- (NSURL*)uniqueURL
{
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *DestFilename = [NSString stringWithFormat:@"%@.MOV", guid];
    
    //Set the file save to URL
    NSString *DestPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CSLVideos"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DestPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    
    DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
    return [[NSURL alloc] initFileURLWithPath:DestPath];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Are we recording frames right now?
    if(writingFrames && assetWriterInput.readyForMoreMediaData) {
        // Has the correct number of frames been captured?
        if ((videoTime.value/30.0) >= 5.0 ) {
            // Pass
        }
        else {
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            // Send the frame to the processing object
            [processingDelegate processFrame:self Buffer:imageBuffer];
            
            // Pass the frame to the asset writer
            [pixelBufferAdaptor appendPixelBuffer:imageBuffer withPresentationTime:videoTime];
            videoTime.value += 1;
        }
    }
}

- (void)captureWithDuration:(Float32)duration {
    // Start recording
    
    self.assetWriter = [[AVAssetWriter alloc]
                        initWithURL:[self uniqueURL]
                        fileType:AVFileTypeMPEG4
                        error:nil];
    [assetWriter addInput:assetWriterInput];
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    videoTime = CMTimeMake(0, 30); // Set timescale at 30 frames per second
    
    [NSTimer scheduledTimerWithTimeInterval:duration/100.0
                                     target:self
                                   selector:@selector(progressClockAction:)
                                   userInfo:nil
                                    repeats:YES];
    writingFrames = YES;
}

- (void)recordingComplete
{
    NSLog(@"Video Time: %lld", videoTime.value);
    writingFrames = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        // Signal to the processing delegate that we are done recording frames
        [processingDelegate didFinishRecordingFrames:self];
    });
    [assetWriterInput markAsFinished];
    // Let the asset writer finish on his own
    [assetWriter finishWritingWithCompletionHandler:^(){
        // Signal the delegate that recording is complete
        [recordingDelegate captureOutput:nil didFinishRecordingToOutputFileAtURL:temporaryOutputPath fromConnections:nil error:nil];
    }];
}

- (void)progressClockAction:(NSTimer *) theTimer
{
    if ((videoTime.value/30.0) >= 5.0) {
        [self recordingComplete];
        [theTimer invalidate];
    }
    captureProgress += 0.01;
    [progressDelegate updateProgress:[NSNumber numberWithFloat:captureProgress]];
    if(captureProgress >= 1.0) {
        // Pass
    }
}

- (void)startCamera
{
    [session startRunning];
}

- (void)stopCamera
{
    [session stopRunning];
    [session removeOutput:videoHDOutput];
    [session removeOutput:videoPreviewOutput];
    [session removeInput:input];
    [videoPreviewLayer removeFromSuperlayer];
    videoPreviewLayer = nil;
    session = nil;
    
    [self clearObservers];
}

#pragma mark - Physical settings

- (void)setManualFocusState
{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeLocked];
    [device unlockForConfiguration];
}

- (void)setContinuousAutoFocusState
{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    [device unlockForConfiguration];
}

- (void)setImmediateAutoFocusState
{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeAutoFocus];
    [device unlockForConfiguration];
}

- (void)setFocusLensPosition:(NSNumber*)position
{
    [device lockForConfiguration:nil];
    [device setFocusModeLockedWithLensPosition:position.floatValue completionHandler:^(CMTime syncTime) {}];
    [device unlockForConfiguration];
}

- (void)setImmediateWhiteBalanceState
{
    [device lockForConfiguration:nil];
    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    [device unlockForConfiguration];
}

- (void)setContinuousWhiteBalanceState
{
    [device lockForConfiguration:nil];
    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    [device unlockForConfiguration];
}

- (void)setLockedWhiteBalanceState
{
    [device lockForConfiguration:nil];
    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
    [device unlockForConfiguration];
}

- (void)setRelativeExposure:(float)value
{
    CMTime min = device.activeFormat.minExposureDuration;
    CMTime max = device.activeFormat.maxExposureDuration;
    CMTime range = CMTimeSubtract(max, min);
    CMTime target = CMTimeAdd(CMTimeMultiplyByFloat64(range, value), min);
    
    [device lockForConfiguration:nil];
    [device setExposureModeCustomWithDuration:target ISO:device.ISO completionHandler:nil];
    [device unlockForConfiguration];
}

- (void)setRelativeISO:(float)iso
{
    float min = device.activeFormat.minISO;
    float max = device.activeFormat.maxISO;
    float value = (max-min)*iso + min;
    [device lockForConfiguration:nil];
    [device setExposureModeCustomWithDuration:device.exposureDuration ISO:value completionHandler:nil];
    [device unlockForConfiguration];
}

// Camera properties
- (NSNumber*)focusLensPosition
{
    return [NSNumber numberWithFloat:device.lensPosition];
}

// Autofocus observers
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        if (focusDelegate != nil) {
            [focusDelegate focusDidChange:[NSNumber numberWithFloat:device.lensPosition]];
        }
    }
}

// Register observer
- (void)registerObservers
{
    int flags = NSKeyValueObservingOptionNew;
    [device addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
}

// Unregister observer
- (void)clearObservers
{
    [device removeObserver:self forKeyPath:@"adjustingFocus"];
}

#pragma mark - UI output

- (void)setPreviewLayer:(CALayer*)viewLayer
{
    // Setup image preview layer
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: self.session];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    videoPreviewLayer.frame = viewLayer.bounds;
    NSMutableArray *layers = [NSMutableArray arrayWithArray:viewLayer.sublayers];
    [layers insertObject:videoPreviewLayer atIndex:0];
    viewLayer.sublayers = [NSArray arrayWithArray:layers];
}

@end
