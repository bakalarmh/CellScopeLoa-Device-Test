//
//  BLEManager.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLE.h"

@protocol BLEManagerDelegate
- (void)bluetoothStateDidChange:(CBCentralManagerState)state;
- (void)didUpdateDevices;
- (void)didConnect;
- (void)didDisconnect;
@end

@interface BLEManager : NSObject <BLEDelegate>

extern int const BluetoothPowered;

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) NSMutableArray* mDevices;
@property (strong, nonatomic) NSMutableArray* mDevicesName;
@property (strong, nonatomic) NSMutableArray* mPeripherals;
@property (strong, nonatomic) NSString *lastUUID;
@property (assign, nonatomic) BOOL connected;

@property (weak, nonatomic) id<BLEManagerDelegate> delegate;

- (void)seekDevices;
- (void)connectionTimer:(NSTimer *)timer;
- (void)storeDefaultUUID:(NSString*)newUUID;
- (void)connectWithUUID:(NSString*)UUID;
- (void)clearConnections;

@end
