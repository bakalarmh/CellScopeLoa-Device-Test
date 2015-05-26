//
//  MotionAnalysis.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 1/26/13.
//  Copyright (c) 2013 Matthew Bakalar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "FrameBuffer.h"

@interface MAMotionObjects: NSObject

@property (assign, nonatomic) NSInteger x;
@property (assign, nonatomic) NSInteger y;
@property (assign, nonatomic) NSInteger start;
@property (assign, nonatomic) NSInteger end;

@end

@interface MotionAnalysis : NSObject

-(id)initWithWidth:(NSInteger)width Height:(NSInteger)height
            Frames:(NSInteger)frames
        VideoCount:(NSInteger)maxVideos;

- (void)processFrameBuffer:(FrameBuffer*)frameBuffer withResourceURL:(NSString*)videoURL;

@end
