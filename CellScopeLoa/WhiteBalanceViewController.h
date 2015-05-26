//
//  WhiteBalanceViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"
#import "LLCamera.h"

@interface WhiteBalanceViewController : UIViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (strong, nonatomic) LLCamera* camera;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockBarButtonItem;
- (IBAction)lockButtonPressed:(id)sender;

@end
