//
//  TestViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestRecord.h"
#import "CaptureViewController.h"
#import "CSLContext.h"
#import <CoreLocation/CoreLocation.h>

@interface TestViewController : UITableViewController <UIAlertViewDelegate, CLLocationManagerDelegate, CaptureViewControllerDelegate>

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;

@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellscopeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *capLabel1;
@property (weak, nonatomic) IBOutlet UILabel *capLabel2;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resultsButtonItem;

@property (weak, nonatomic) NSString* patientNIHID;
@property (weak, nonatomic) NSString* testNIHID;

@property (assign, nonatomic) BOOL newTest;

- (IBAction)cancelPushed:(id)sender;
- (IBAction)capturePushed:(id)sender;
- (IBAction)changeIDPushed:(id)sender;

@end
