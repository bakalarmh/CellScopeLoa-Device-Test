//
//  ExposureISOViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/13/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"
#import "LLCamera.h"

@interface ExposureISOViewController : UIViewController

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) CSLContext *cslContext;

@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (strong, nonatomic) LLCamera* camera;
@property (weak, nonatomic) IBOutlet UITextField *exposureTextField;
@property (weak, nonatomic) IBOutlet UITextField *ISOTextField;
@property (weak, nonatomic) IBOutlet UISlider *exposureSlider;
@property (weak, nonatomic) IBOutlet UISlider *isoSlider;

- (IBAction)exposureSliderChanged:(id)sender;
- (IBAction)ISOSliderChanged:(id)sender;

@end
