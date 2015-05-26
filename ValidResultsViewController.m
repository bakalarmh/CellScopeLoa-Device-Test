//
//  ValidResultsViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/15/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "ValidResultsViewController.h"
#import "TestValidation.h"

@interface ValidResultsViewController ()

@end

@implementation ValidResultsViewController

@synthesize cslContext;
@synthesize finishedButtonItem;
@synthesize mffieldLabel;
@synthesize mfmlLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    
    NSDictionary* testResults = [TestValidation ResultsFromTestRecord:cslContext.activeTestRecord];
    
    NSNumber* objectsPerField = [testResults objectForKey:@"ObjectsPerField"];
    
    NSNumber* objectsPerMl = [testResults objectForKey:@"ObjectsPerMl"];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    NSString* mfmlString = [formatter stringFromNumber:objectsPerMl];
    
    mffieldLabel.text = [NSString stringWithFormat:@"%.2f mf/field", objectsPerField.floatValue];
    mfmlLabel.text = [NSString stringWithFormat:@"%@ mf/ml", mfmlString];
    
    // Store the output in the ManagedObjectContext
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ReturnToMenu"]) {
        NSLog(@"Back to menu");
    }
}

- (IBAction)finishedPressed:(id)sender {
    [self performSegueWithIdentifier:@"ReturnToMenu" sender:self];
}
@end
