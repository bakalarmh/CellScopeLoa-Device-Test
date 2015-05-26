//
//  deviceConnectionDelegate.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BluetoothScanner <NSObject>

- (NSMutableArray*)listDetectedBoards;

@end
