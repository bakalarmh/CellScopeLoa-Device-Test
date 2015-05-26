//
//  CameraDataDispatcher.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LLCamera;

@interface CameraDispatcher : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (weak, nonatomic) LLCamera* camera;

- (id)initWithCamera:(LLCamera*)cam;
- (void)recordVideoFileOutput;
- (void)stopDispatcher;

@end