//
//  CameraDataDispatcher.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "CameraDispatcher.h"
#import "LLCamera.h"

@implementation CameraDispatcher {
    AVCaptureVideoDataOutput* dataOutput;
    AVAssetWriterInput* writerInput;
    AVAssetWriter* assetWriter;
    AVAssetWriterInputPixelBufferAdaptor* pixelBufferAdaptor;
    dispatch_queue_t dataQueue;
    BOOL writingFrames;
    CMTime videoTime;
    int videoCount;
}

@synthesize camera;

- (id)initWithCamera:(LLCamera*)cam
{
    self = [super init];
    self.camera = cam;
    
    // Manage the sample buffer
    writingFrames = NO;
    
    // Set up the data outputs and connect to camera session
    [self initDataOutput];

    return self;
}

- (void)initDataOutput
{
    // Setup live processing output
    dataOutput = [AVCaptureVideoDataOutput new];
    dataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [dataOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    if ([camera.session canAddOutput:dataOutput]) {
        [camera.session addOutput:dataOutput];
    }
    
    AVCaptureConnection *captureConnection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoOrientationSupported]) {
        [captureConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    }
    
    // Setup frame buffer
    dataQueue = dispatch_queue_create("CSL.sampleBufferDataQueue", NULL);
    [dataOutput setSampleBufferDelegate:self queue:dataQueue];
}

- (void)initAssetWriterWithURL:(NSURL*)assetURL
{
    NSDictionary *outputSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:480], AVVideoWidthKey,
     [NSNumber numberWithInt:360], AVVideoHeightKey,
     AVVideoCodecH264, AVVideoCodecKey,
     nil];
    
    writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    
    // 32BGRA Pixel adaptor
    pixelBufferAdaptor =
    [[AVAssetWriterInputPixelBufferAdaptor alloc]
     initWithAssetWriterInput:writerInput
     sourcePixelBufferAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
      kCVPixelBufferPixelFormatTypeKey,
      nil]];
    // Expect real time data
    writerInput.expectsMediaDataInRealTime = YES;
    
    NSError *assetWriterError;
    assetWriter = [[AVAssetWriter alloc]
                   initWithURL:assetURL
                   fileType:AVFileTypeMPEG4
                   error:&assetWriterError];
    
    [assetWriter addInput:writerInput];
    [assetWriter startWriting];
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
}

- (NSURL*)testURL
{
    NSString *DestFilename = @ "test.mov";
    
    //Set the file save to URL
    NSLog(@"Starting recording to file: %@", DestFilename);
    NSString *DestPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Record"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DestPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    
    DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
    return [[NSURL alloc] initFileURLWithPath:DestPath];
}

- (void)recordVideoFileOutput
{
    // Initialize the asset writer
    [self initAssetWriterWithURL:[self testURL]];
    
    videoTime = CMTimeMake(0, 30); // Set timescale at 30 frames per second
    videoCount = 0;
    writingFrames = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"5 Seconds has elapsed");
        writingFrames = NO;
        [writerInput markAsFinished];
        [assetWriter finishWritingWithCompletionHandler:^(){
            NSLog (@"finished writing");
        }];
    });
}

- (void)stopDispatcher
{
    // Remove the video file output from the session
    if ([camera.session.outputs containsObject:dataOutput]) {
        [camera.session removeOutput:dataOutput];
    }
}

#pragma mark - ProcessingDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(writingFrames) {
        if (writerInput.readyForMoreMediaData) {
            NSLog(@"Ready for new media data");
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            [pixelBufferAdaptor appendPixelBuffer:imageBuffer withPresentationTime:videoTime];
        
            videoTime.value += 1;
            videoCount += 1;
        }
        else {
            NSLog(@"Writer input not read");
        }
        NSLog(@"%d", videoCount);
    }
}

@end