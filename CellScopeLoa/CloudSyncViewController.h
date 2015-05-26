//
//  CloudSyncViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/17/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"

@interface CloudSyncViewController : UIViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;
@property (weak, nonatomic) IBOutlet UILabel *dataReportLabel;

- (IBAction)syncButtonPressed:(id)sender;

@end
