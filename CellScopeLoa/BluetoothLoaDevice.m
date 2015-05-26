//
//  BluetoothLoaDevice.m
//  CellScopeLoa
//
//  Created by Mike D'Ambrosio on 5/8/14.
//  Copyright (c) 2014 Matthew Bakalar. All rights reserved.
//

#import "BluetoothLoaDevice.h"

@implementation BluetoothLoaDevice {
    int currentPos;
    int servoStep;
}

@synthesize bleManager;
@synthesize ble;

- (id)initWithBLEManager:(BLEManager*)manager
{
    self = [super init];
    self.bleManager = manager;
    self.ble = manager.ble;
    // Default advance step for the servo
    servoStep = (152-32)/8;
    
    return self;
}

- (void)servoReturn
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    buf[1]= 32;
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    currentPos = 32;
}

- (void)LEDOn
{
    UInt8 buf[3] = {0x05, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

- (void)LEDOff
{
    UInt8 buf[3] = {0x06, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

- (void)iled1Toggle:(int) on
{ //not ready to be used yet
    if (on==1) {
        UInt8 buf[3] = {0x07, 0x01, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
    else {
        UInt8 buf[3] = {0x07, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
}

- (void)iled2Toggle:(int) on {
    if (on==1) {
        UInt8 buf[3] = {0x08, 0x01, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
    else {
        UInt8 buf[3] = {0x08, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
}

- (void)iled3Toggle:(int) on {
    if (on==1) {
        UInt8 buf[3] = {0x09, 0x01, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
    else {
        UInt8 buf[3] = {0x09, 0x00, 0x00};
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
    }
}

- (void)ledPulse:(int) iledNum:(float) onTime: (NSNumber *) numPulse { //iledNum can be 1, 2, or 3.
    if (iledNum==1) {
        NSNumber *stopNum = [NSNumber numberWithInt:numPulse];
        NSNumber *currNum = [NSNumber numberWithInt:0];
        
        NSArray* timerInfo = [NSArray arrayWithObjects:currNum ,stopNum,nil];
        
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:iledNum
                                                          target:self
                                                        selector:@selector(handleIled1Timer:)
                                                        userInfo:timerInfo repeats:NO];
    }
}

- (void)handleIled1Timer:(NSTimer*)iled1Timer {
    //NSLog (@"Got the string: %@", (NSString*)[iled1Timer userInfo]);
}

- (void)servoLoadPosition
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    buf[1]= 25;
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    currentPos = 25;
}

- (void)servoFarPostition
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    buf[1]= 152;
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    currentPos = 152;
}

- (void)servoAdvance
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    int testPos = currentPos + servoStep;
    if (testPos > 152) {
        NSLog(@"Servo is at maximum position");
    }
    else {
        buf[1] = testPos;
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
        currentPos = testPos;
    }
}

- (void)servoRetract
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    int testPos = currentPos - servoStep;
    if (testPos < 32) {
        NSLog(@"Servo is at minimum position");
    }
    else {
        buf[1] = testPos;
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
        currentPos = testPos;
    }
}

-(void) servoPartialAdvance:(float)fraction
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    int testPos = currentPos + (int)servoStep*fraction;
    if (testPos > 152) {
        NSLog(@"Servo is at maximum position");
    }
    else {
        buf[1] = testPos;
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];
        currentPos = testPos;
    }
}


// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            //if (data[i+1] == 0x01)
            //swDigitalIn.on = true;
            //else
            //swDigitalIn.on = false;
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            //lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end