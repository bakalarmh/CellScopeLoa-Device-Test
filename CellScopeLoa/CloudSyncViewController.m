//
//  CloudSyncViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/17/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "CloudSyncViewController.h"
#import "TestRecord.h"
#import "ParseDataAdaptor.h"

@interface CloudSyncViewController ()

@end

@implementation CloudSyncViewController

@synthesize managedObjectContext;
@synthesize cslContext;

@synthesize dataReportLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)syncButtonPressed:(id)sender {
    NSError *error;
    
    NSString *sortKey = @"created";
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Query all TestRecords from CoreData
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TestRecord"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (TestRecord* record in fetchedObjects) {
        NSLog(@"Record: %@", record.simpleTestID);
        [ParseDataAdaptor syncTestRecord:record WithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                    dataReportLabel.text = @"All data synced";
                }];
            }
            else {
                NSLog(@"Parse error: %@", error.description);
            }
        }];
    }
}


@end
