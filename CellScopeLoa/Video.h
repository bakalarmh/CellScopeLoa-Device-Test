//
//  Video.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/15/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MotionObject;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSNumber * averageObjectCount;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * fieldIndex;
@property (nonatomic, retain) NSString * resourceURL;
@property (nonatomic, retain) NSString * errorString;
@property (nonatomic, retain) NSString * testUUID;
@property (nonatomic, retain) NSNumber * capillaryIndex;
@property (nonatomic, retain) MotionObject *motionObjects;

@end
