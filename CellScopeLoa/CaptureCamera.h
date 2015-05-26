//
//  CaptureCamera.h
//  CellScopeLoa2
//
//  Created by Matthew Bakalar on 1/11/14.
//  Copyright (c) 2014 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol FocusDelegate
- (void)focusDidChange:(NSNumber*)focusLensPosition;
@end

// Forward declaration
@class CaptureCamera;

@protocol FrameProcessingDelegate

- (void)processFrame:(CaptureCamera*)sender Buffer:(CVBufferRef)buffer;
- (void)didFinishRecordingFrames:(CaptureCamera*)sender;

@end

@protocol CaptureProgressDelegate

- (void)updateProgress:(NSNumber*)progress;

@end

@interface CaptureCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

// Delegates
@property (nonatomic, strong) id<AVCaptureFileOutputRecordingDelegate> recordingDelegate;
@property (weak, nonatomic) id<FocusDelegate> focusDelegate;
@property (nonatomic, strong) id<FrameProcessingDelegate> processingDelegate;
@property (nonatomic, strong) id<CaptureProgressDelegate> progressDelegate;

// AVFoundation resources
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoPreviewOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoHDOutput;

@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *pixelBufferAdaptor;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterInput;
@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* videoPreviewLayer;

@property (nonatomic, strong) NSNumber* width;
@property (nonatomic, strong) NSNumber* height;
@property (weak, nonatomic) NSNumber* focusLensPosition;

// Camera state properties
@property (nonatomic, strong) NSURL* temporaryOutputPath;

- (id)initWithWidth:(NSInteger)frameWidth Height:(NSInteger)frameHeight;

- (void)setManualFocusState;
- (void)setContinuousAutoFocusState;
- (void)setImmediateAutoFocusState;
- (void)setImmediateWhiteBalanceState;
- (void)setContinuousWhiteBalanceState;
- (void)setLockedWhiteBalanceState;
- (void)setRelativeExposure:(float)value;
- (void)setRelativeISO:(float)iso;

- (void)setPreviewLayer:(CALayer*)viewLayer;
- (void)startCamera;
- (void)stopCamera;
- (void)captureWithDuration:(Float32)duration;

@end
