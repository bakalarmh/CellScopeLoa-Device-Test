//
//  TextBluetoothScanner.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "TextBluetoothScanner.h"

@implementation TextBluetoothScanner {
    NSMutableArray* detectedBoards;
}

- (NSMutableArray*)listDetectedBoards
{
    NSMutableArray *boards = [NSMutableArray arrayWithObjects:@"001", @"002", @"003", nil];
    return boards;
}

@end