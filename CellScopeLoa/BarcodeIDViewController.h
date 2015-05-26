//
//  TestIDViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"

@interface BarcodeIDViewController : UIViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UIButton *textEntryButton;

@property (assign, nonatomic) BOOL recaptureID;

@end
