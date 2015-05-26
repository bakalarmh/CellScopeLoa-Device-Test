//
//  BLEManager.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/10/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "BLEManager.h"
#import "constants.h"

@implementation BLEManager {
    int bluetoothState;
}

@synthesize ble;
@synthesize mDevices;
@synthesize mDevicesName;
@synthesize mPeripherals;
@synthesize delegate;
@synthesize lastUUID;
@synthesize connected;

int const BluetoothPowered = 5;

- (id)init
{
    // Set up the BLE device
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    bluetoothState = 0;
    connected = NO;
    
    mDevices = [[NSMutableArray alloc] init];
    mDevicesName = [[NSMutableArray alloc] init];
    mPeripherals = [[NSMutableArray alloc] init];
    
    lastUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUIDPrefKey];
    
    return self;
}

- (void)seekDevices
{
    [self clearConnections];
    [mDevices removeAllObjects];
    [mDevicesName removeAllObjects];
    [mPeripherals removeAllObjects];
    
    if (ble.peripherals)
        ble.peripherals = nil;
    [ble findBLEPeripherals:3];
    
    int delay = 1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        for (int i = 0; i < ble.peripherals.count; i++)
        {
            CBPeripheral *p = [ble.peripherals objectAtIndex:i];
            if (p.identifier != NULL)
            {
                NSUUID* pid = p.identifier;
                [mDevices insertObject:pid.UUIDString atIndex:i];
                [mPeripherals insertObject:p atIndex:i];
            }
        }
        [delegate didUpdateDevices];
    });
}

- (void)clearConnections
{
    if (ble.activePeripheral) {
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            return;
        }
    }
}

- (void)storeDefaultUUID:(NSString*)newUUID
{
    [[NSUserDefaults standardUserDefaults] setObject:newUUID forKey:UUIDPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    lastUUID = newUUID;
}

- (void)connectWithUUID:(NSString*)UUID
{
    for (int i = 0; i < mDevices.count; i++) {
        if ([[mDevices objectAtIndex:i] isEqualToString:UUID]) {
            CBPeripheral *p = (CBPeripheral*)[mPeripherals objectAtIndex:i];
            [ble connectPeripheral:p];
        }
    }
}

- (void)bleDidConnect
{
    NSLog(@"->DidConnect");
    connected = YES;
    [delegate didConnect];
}

- (void)bleDidDisconnect
{
    NSLog(@"->DidDisconnect");
    connected = NO;
    [delegate didDisconnect];
}

- (void)bleDidReceiveData:(unsigned char *)data length:(int)length
{
    // Pass
}

- (void)bleDidUpdateRSSI:(NSNumber *) rssi
{
    NSLog(@"Did update RSSI");
}

- (void)bleCoreBluetoothChange:(CBCentralManager*)manager
{
    [delegate bluetoothStateDidChange:manager.state];
}

-(NSString *)getUUIDString:(CFUUIDRef)ref {
    NSString *str = [NSString stringWithFormat:@"%@", ref];
    return [[NSString stringWithFormat:@"%@", str] substringWithRange:NSMakeRange(str.length - 36, 36)];
}


@end
