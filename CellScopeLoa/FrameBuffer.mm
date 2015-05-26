//
//  FrameBuffer.m
//  LoaTestkit
//
//  Created by Matthew Bakalar on 1/10/14.
//  Copyright (c) 2014 Matthew Bakalar. All rights reserved.
//

#import "FrameBuffer.h"
#import "UIImage+OpenCV.h"

#include <vector>

@implementation FrameBuffer {
    std::vector<cv::Mat> *buffer;
    bool cleared;
}

@synthesize frameWidth;
@synthesize frameHeight;
@synthesize numFrames;

- (id)initWithWidth:(NSInteger)width Height:(NSInteger)height Frames:(NSInteger)frames
{
    cleared = false;
    frameWidth = [NSNumber numberWithInt:width];
    frameHeight = [NSNumber numberWithInt:height];
    numFrames = [NSNumber numberWithInt:frames];
    
    buffer = new std::vector<cv::Mat>(numFrames.intValue);
    for(int i = 0; i < numFrames.intValue; i++) {
        cv::Mat frame(frameHeight.intValue, frameWidth.intValue, CV_8UC1);
        buffer->at(i) = frame;
    }
    
    return self;
}

- (cv::Mat)getFrameAtIndex:(NSInteger)index
{
    if (cleared) {
        NSLog(@"!!!!!!!! Read from cleared buffer !!!!!!!!");
    }
    return buffer->at(index);
}

- (UIImage*)getUIImageFromIndex:(NSInteger)index
{
    return [UIImage imageWithCVMat:buffer->at(index)];
}

- (NSArray*)getUIImageArray
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i=0; i < numFrames.intValue; i++) {
        [array addObject:[UIImage imageWithCVMat:buffer->at(i)]];
    }
    return array;
}

- (void)releaseFrameBuffers
{
    for(int i=0; i<[numFrames intValue]; i++){
        buffer->at(i).release();
        buffer->at(i) = cv::Mat();
    }
    cleared = true;
}

- (void)writeFrame:(CVBufferRef)imageBuffer atIndex:(NSNumber*)index
{
    if (index.intValue >= numFrames.intValue) {
        NSLog(@"Cannot write frame over the end of the buffer");
    }
    else {
        // Lock the image buffer
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        // Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a CGImageRef from the CVImageBufferRef
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        // This copies the data, may be eliminated to optimize code later on
        CGImageRef image = CGBitmapContextCreateImage(newContext);
        // Cleanup the CG creators
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
        
        // Unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        colorSpace = CGImageGetColorSpace(image);
        CGFloat cols = width;
        CGFloat rows = height;
        
        // Create an RGBA frame for converting the CGImage
        
        // Grab the current movie from the frame buffer list
        cv::Mat grayBuffer = buffer->at(index.intValue);
        
        // Create a grayscale opencv image from the RGBA buffer
        cv::Mat colorimage(rows,cols,CV_8UC4);
        
        CGContextRef contextRef = CGBitmapContextCreate(colorimage.data,                 // Pointer to  data
                                                        cols,                       // Width of bitmap
                                                        rows,                       // Height of bitmap
                                                        8,                          // Bits per component
                                                        colorimage.step[0],              // Bytes per row
                                                        colorSpace,                 // Colorspace
                                                        kCGImageAlphaNoneSkipLast |
                                                        kCGBitmapByteOrderDefault); // Bitmap info flags
        
        CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image);
        CGContextRelease(contextRef);
        // CGColorSpaceRelease(colorSpace);
        // Release the CGImage memory. This is a place for optimization
        CGImageRelease(image);
        
        // Copy the color image into the grayscale buffer
        cv::cvtColor(colorimage, grayBuffer, CV_BGRA2GRAY);
    }
}


@end
