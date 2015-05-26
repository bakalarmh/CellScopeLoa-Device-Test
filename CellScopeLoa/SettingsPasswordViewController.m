//
//  SettingsPasswordViewController.m
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/11/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import "SettingsPasswordViewController.h"
#import "SettingsTableViewController.h"
#import "constants.h"

@interface SettingsPasswordViewController ()

@end

@implementation SettingsPasswordViewController

@synthesize cslContext;
@synthesize PasswordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PasswordField.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    PasswordField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    NSString* adminPass = [[NSUserDefaults standardUserDefaults] objectForKey:AdminPassKey];
    if ([textField.text isEqualToString:adminPass]) {
        [self performSegueWithIdentifier:@"EditSettings" sender:self];
    }
    else {
        textField.text = @"";
        int direction = 1;
        [UIView animateWithDuration:0.2 animations:^
         {
             textField.transform = CGAffineTransformMakeTranslation(5*direction, 0);
         } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.2 animations:^
              {
                  textField.transform = CGAffineTransformMakeTranslation(-5*direction, 0);
              } completion:^(BOOL finished) {}];
         }];
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"EditSettings"]) {
        SettingsTableViewController* vc = (SettingsTableViewController*)segue.destinationViewController;
        vc.cslContext = cslContext;
    }
}

@end
