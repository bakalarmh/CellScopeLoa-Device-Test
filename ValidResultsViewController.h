//
//  ValidResultsViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/15/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"

@interface ValidResultsViewController : UIViewController

@property (weak, nonatomic) CSLContext* cslContext;
@property (weak, nonatomic) IBOutlet UILabel *mffieldLabel;
@property (weak, nonatomic) IBOutlet UILabel *mfmlLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishedButtonItem;
- (IBAction)finishedPressed:(id)sender;

@end
