//
//  CSLContext.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "CSLContext.h"
#import "TestRecord.h"
#import "constants.h"
#import "BLEManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation CSLContext

@synthesize locationManager;
@synthesize activeTestRecord;
@synthesize capillaryIndex;
@synthesize capillaryProcessingIndex;
@synthesize bleManager;
@synthesize loaDevice;

- (id)init
{
    return self;
}

- (NSString*)generateSimpleCSLIDWithRecord:(TestRecord*)record
{
    NSNumber* testCounter = [[NSUserDefaults standardUserDefaults] objectForKey:TestCounterKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:testCounter.intValue+1] forKey:TestCounterKey];
    
    NSString* counterString = [NSString stringWithFormat:@"%d", testCounter.intValue];
    NSString* ID = [NSString stringWithFormat:@"%@.%@.%@",record.deviceID,record.simplePhoneID,counterString];
    return ID;
}

- (NSURL*)generateUniqueURLWithRecord:(TestRecord*)record;
{
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *DestFilename = [NSString stringWithFormat:@"%@.MOV", guid];
    
    //Set the file save to URL
    NSString *DestPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CSLVideos"];
    DestPath = [DestPath stringByAppendingPathComponent:record.deviceID];
    DestPath = [DestPath stringByAppendingPathComponent:record.simpleTestID];
    DestPath = [DestPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",capillaryIndex.intValue]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:DestPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DestPath withIntermediateDirectories:YES attributes:nil error:nil]; //Create folder
    }
    
    DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
    return [[NSURL alloc] initFileURLWithPath:DestPath];
}

- (BOOL)deviceIsConnected
{
    if ((bleManager != nil) && ([bleManager connected])){
        return YES;
    }
    else {
        return NO;
    }
}

- (CLLocationManager*)locationManager
{
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
    }
    return locationManager;
}

- (void)startLocationUpdates
{
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 1000; // meters
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates
{
    [locationManager stopUpdatingLocation];
}

@end
