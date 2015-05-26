//
//  ManualIDViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/9/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "ManualIDViewController.h"
#import "TestViewController.h"
#import "BarcodeIDViewController.h"

#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-#"

@interface ManualIDViewController ()

@end

@implementation ManualIDViewController {
    NSString* patientIDText;
}

@synthesize managedObjectContext;
@synthesize cslContext;
@synthesize recaptureID;

@synthesize IDTextField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.toolbar setHidden:YES];
    
    IDTextField.delegate = self;
    IDTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    IDTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"StartTest"]) {
        [self.navigationController.toolbar setHidden:NO];
        TestViewController* vc = (TestViewController*)segue.destinationViewController;
        vc.managedObjectContext = managedObjectContext;
        vc.cslContext = cslContext;
        vc.patientNIHID = patientIDText;
        if (recaptureID == NO) {
            vc.newTest = YES;
        }
        else {
            vc.NewTest = NO;
        }
        
    }
    
}

// Back button press - in place of a segue
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        // BarcodeIDViewController* vc = (BarcodeIDViewController*)self.parentViewController;
        // vc.recaptureID = recaptureID;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

- (BOOL)textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    patientIDText = textField.text;
    return YES;
}

@end
