//
//  ParseDataAdaptor.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/17/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestRecord.h"
#import "CapillaryRecord.h"

@interface ParseDataAdaptor : NSObject

+ (void)syncTestRecord:(TestRecord*)record WithBlock:(void (^)(BOOL, NSError*))completionBlock;

@end
