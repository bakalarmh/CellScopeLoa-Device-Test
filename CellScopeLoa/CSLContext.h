//
//  CSLContext.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TestRecord.h"
#import "MotionAnalysis.h"
#import "BluetoothLoaDevice.h"
#import "BLEManager.h"

@interface CSLContext : NSObject

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) BLEManager* bleManager;
@property (nonatomic, strong) BluetoothLoaDevice* loaDevice;

@property (strong, nonatomic) TestRecord* activeTestRecord;
@property (weak, nonatomic) CapillaryRecord* activeCapillaryRecord;
@property (strong, nonatomic) NSNumber* capillaryIndex;
@property (strong, nonatomic) NSNumber* capillaryProcessingIndex;
@property (strong, nonatomic) MotionAnalysis* motionAnalysis;

- (void)startLocationUpdates;
- (NSString*)generateSimpleCSLIDWithRecord:(TestRecord*)record;
- (NSURL*)generateUniqueURLWithRecord:(TestRecord*)record;

- (BOOL)deviceIsConnected;

@end
