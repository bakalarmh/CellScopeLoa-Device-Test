//
//  ParseDataAdaptor.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/17/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "ParseDataAdaptor.h"
#import <Parse/Parse.h>

@implementation ParseDataAdaptor

+ (void)syncTestRecord:(TestRecord*)record WithBlock:(void (^)(BOOL, NSError*))completionBlock
{
    PFObject *post = [PFObject objectWithClassName:@"TestRecord"];
    
    [post setObject:record.boardUUID forKey:@"boardUUID"];
    [post setObject:record.created forKey:@"created"];
    [post setObject:record.deviceID forKey:@"deviceID"];
    [post setObject:record.localTimeZone forKey:@"localTimeZone"];
    [post setObject:record.latitude forKey:@"latitude"];
    [post setObject:record.longitude forKey:@"longitude"];
    [post setObject:record.objectsPerMl forKey:@"objectsPerMl"];
    [post setObject:record.objectsPerField forKey:@"objectsPerField"];
    [post setObject:record.patientNIHID forKey:@"patientNIHID"];
    [post setObject:record.phoneIdentifier forKey:@"phoneIdentifier"];
    [post setObject:record.simplePhoneID forKey:@"simplePhoneID"];
    [post setObject:record.simpleTestID forKey:@"simpleTestID"];
    [post setObject:record.state forKey:@"state"];
    [post setObject:record.testUUID forKey:@"testUUID"];
    if (record.testMode != nil) {
        [post setObject:record.testMode forKey:@"testMode"];
    }
    if (record.testNIHID != nil) {
        [post setObject:record.testNIHID forKey:@"testNIHID"];
    }

    // Save it to Parse with completion block
    [post saveInBackgroundWithBlock:completionBlock];
}

/*
- (void)syncCapillaryRecord:(CapillaryRecord*)record withParentTestRecord:(PFObject*)testRecord
{
    PFObject *post = [PFObject objectWithClassName:@"CapillaryRecord"];
    
    [post setObject:record.created forKey:@"created"];
    [post setObject:record.testUUID forKey:@"testUUID"];
    [post setObject:record.errorString forKey:@"errorString"];
    [post setObject:record.objectsPerMl forKey:@"objectsPerMl"];
    [post setObject:record.objectsPerField forKey:@"objectsPerField"];
    [post setObject:record.videos forKey:@"objectsPerMl"];
    [post setObject:record.objectsPerField forKey:@"objectsPerField"];
    
    [post setObject:testRecord forKey:@"testRecord"];
    
    
    [post setObject:record.objectsPerField forKey:@"objectsPerField"];

    PFObject *myComment = [PFObject objectWithClassName:@"Comment"];
    myComment[@"content"] = @"Let's do Sushirrito.";
    
    // Add a relation between the Post and Comment
    myComment[@"parent"] = myPost;
    
    // This will save both myPost and myComment
    [myComment saveInBackground];
}
*/

@end
