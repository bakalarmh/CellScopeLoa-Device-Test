//
//  InvalidResultsViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/17/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "InvalidResultsViewController.h"

@interface InvalidResultsViewController ()

@end

@implementation InvalidResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
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

- (IBAction)finishedPressed:(id)sender {
    [self performSegueWithIdentifier:@"ReturnToMenu" sender:self];
}

@end
