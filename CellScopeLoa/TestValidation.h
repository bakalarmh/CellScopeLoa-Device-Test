//
//  TestValidator.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/15/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestRecord;

@interface TestValidation : NSObject

+ (NSDictionary*)ValidateTestRecord:(TestRecord*)testRecord;
+ (NSDictionary*)ResultsFromTestRecord:(TestRecord*)testRecord;

+ (NSDictionary*)ValidateTestRecordWithUUID:(NSString*)testUUID;

@end
