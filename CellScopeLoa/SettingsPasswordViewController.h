//
//  SettingsPasswordViewController.h
//  CellScopeLoa
//
//  Created by Matthew Bakalar on 5/11/15.
//  Copyright (c) 2015 Fletcher Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSLContext.h"

@interface SettingsPasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) CSLContext* cslContext;

@property (weak, nonatomic) IBOutlet UITextField *PasswordField;

@end
