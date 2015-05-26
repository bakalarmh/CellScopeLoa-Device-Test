//
//  TestValidator.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/15/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "TestValidation.h"
#import "TestRecord.h"
#import "CapillaryRecord.h"
#import "Video.h"
#import "constants.h"

@implementation TestValidation

+ (NSDictionary*)ValidateTestRecord:(TestRecord*)testRecord
{
    BOOL capillaryCheck = (testRecord.capillaryRecords.count == 2);
    
    BOOL videoErrorCheck = YES;
    BOOL videoCountCheck = YES;
    BOOL videoObjectCheck = YES;
    NSInteger maxFields = [[[NSUserDefaults standardUserDefaults] objectForKey:FieldsOfViewKey] integerValue];
    for (CapillaryRecord* record in testRecord.capillaryRecords) {
        if (record.videos.count != maxFields) {
            videoCountCheck = NO;
        }
        for (Video* video in record.videos) {
            if (![video.errorString isEqualToString:@"None"]) {
                videoErrorCheck = NO;
            }
            if (video.averageObjectCount >= 0) {
                // Pass
            }
            else {
                videoObjectCheck = NO;
            }
        }
    }
    
    NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
    
    if (capillaryCheck && videoErrorCheck && videoObjectCheck && videoObjectCheck) {
            [results setObject:@"Valid" forKey:@"Code"];
    }
    else {
        if (videoErrorCheck == NO) {
            NSLog(@"Validation detected a video error");
            [results setObject:@"Invalid" forKey:@"Code"];
        }
    }
    
    return results;
}

// Method also stores results in CoreData objects
+ (NSDictionary*)ResultsFromTestRecord:(TestRecord *)testRecord
{
    NSNumber* capillaryVolume = [[NSUserDefaults standardUserDefaults] objectForKey:CapillaryVolumeKey];

    NSMutableArray* capillaryMeans = [[NSMutableArray alloc] init];
    for (CapillaryRecord* record in testRecord.capillaryRecords) {
        float sum = 0;
        int counter = 0;
        for (Video* video in record.videos) {
            float count = video.averageObjectCount.floatValue;
            sum += count;
            counter += 1;
        }
        float mean = sum/counter;
        NSNumber* value = [NSNumber numberWithFloat:mean];
        // Store in CoreData
        record.objectsPerField = value;
        [capillaryMeans addObject:value];
    }
    
    float capillarySum = 0.0;
    int capillaryCount = 0;
    for (NSNumber* cmean in capillaryMeans) {
        capillarySum += cmean.floatValue;
        capillaryCount += 1;
    }
    
    float objectsPerField = capillarySum/capillaryCount;
    
    float objectsPerMl = objectsPerField/capillaryVolume.floatValue;
    
    NSMutableDictionary* results = [[NSMutableDictionary alloc] init];
    [results setObject:[NSNumber numberWithFloat:objectsPerField] forKey:@"ObjectsPerField"];
    [results setObject:[NSNumber numberWithFloat:objectsPerMl] forKey:@"ObjectsPerMl"];
    
    return results;
}


+ (NSDictionary*)ValidateTestRecordWithUUID:(NSString*)testUUID
{
    NSLog(@"Validate: %@", testUUID);
    return nil;
}

@end
