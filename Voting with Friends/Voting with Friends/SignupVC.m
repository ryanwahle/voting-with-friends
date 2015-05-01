//
//  SignupVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/22/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "SignupVC.h"

@interface SignupVC ()

@property (weak, nonatomic) IBOutlet UITextField *nameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *emailUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;

@end

@implementation SignupVC

// Take the border off the textfields (which is left on so I can see them in IB) and then call the custom graphic code.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _nameUITextField.borderStyle = UITextBorderStyleNone;
    _emailUITextField.borderStyle = UITextBorderStyleNone;
    _passwordUITextField.borderStyle = UITextBorderStyleNone;
    
    [self.nameUITextField layoutIfNeeded];
    [self.emailUITextField layoutIfNeeded];
    [self.passwordUITextField layoutIfNeeded];
    
    [_nameUITextField.layer addSublayer:[self createTextFieldBottomBorder:_nameUITextField]];
    [_emailUITextField.layer addSublayer:[self createTextFieldBottomBorder:_emailUITextField]];
    [_passwordUITextField.layer addSublayer:[self createTextFieldBottomBorder:_passwordUITextField]];

    [_nameUITextField becomeFirstResponder];
}

// This is where we draw the custom graphics for the textfields.
- (CALayer *)createTextFieldBottomBorder:(UITextField *)textField {
    CALayer *textFieldBorder = [CALayer layer];
    CGFloat borderWidth = 1;
    
    textFieldBorder.borderColor = [UIColor lightGrayColor].CGColor;
    textFieldBorder.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    textFieldBorder.borderWidth = borderWidth;
    
    return textFieldBorder;
}



// Verify the users input and try to sign up a user within the parse database.
- (IBAction)signupNewUser:(UIButton *)sender {
    NSString *emailString = [_emailUITextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordString = [_passwordUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nameString = [_nameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( ! emailString.length) {
        [self signUpFailedAlert:@"You must enter an email address to sign up."];
    } else if ( ! passwordString.length) {
        [self signUpFailedAlert:@"You must enter a password to sign up."];
    } else if ( ! nameString.length) {
        [self signUpFailedAlert:@"You must enter your name to sign up."];
    } else {
        PFUser *newUser = [PFUser user];
        
        newUser.username = emailString;
        newUser.password = passwordString;
        newUser.email = emailString;
        
        newUser[@"name"] = nameString;

        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self dismissSignup:nil];
            } else {
                [self signUpFailedAlert:error.userInfo[@"error"]];
            }
        }];
    }
}

// Alert box
- (void)signUpFailedAlert:(NSString *)alertString {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up Failed" message:alertString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)dismissSignup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
