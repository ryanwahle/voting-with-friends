//
//  LoginVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/19/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "LoginVC.h"
#import "VFPush.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *loginUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;

@end

@implementation LoginVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Make some UI changes to the text fields.
    
    _loginUITextField.borderStyle = UITextBorderStyleNone;
    [_loginUITextField.layer addSublayer:[self createTextFieldBottomBorder:_loginUITextField]];
    
    _passwordUITextField.borderStyle = UITextBorderStyleNone;
    [_passwordUITextField.layer addSublayer:[self createTextFieldBottomBorder:_passwordUITextField]];
    
    [_loginUITextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // If user is already logged in then move on
    if ([PFUser currentUser]) {
        [self loginSuccesful];
    }
}

- (IBAction)signInButtonTap:(id)sender {
    
    NSString *emailString = [self.loginUITextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordString = [self.passwordUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( ! emailString.length) {
        [self signInFailedAlert:@"You must enter an email address to sign in." withTitle:@"Sign In Failed"];
    } else if ( ! passwordString.length) {
        [self signInFailedAlert:@"You must enter a password to sign in." withTitle:@"Sign In Failed"];
    } else {
        [PFUser logInWithUsernameInBackground:self.loginUITextField.text.lowercaseString password:self.passwordUITextField.text block:^(PFUser *user, NSError *error) {
            if (user) {
                [self loginSuccesful];
            } else {
                [self signInFailedAlert:@"Your email and password do not match." withTitle:@"Sign In Failed"];
            }
        }];
    }
}

- (IBAction)forgetPasswordButtonTap:(id)sender {
    NSString *emailString = [self.loginUITextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( ! emailString.length ) {
        [self signInFailedAlert:@"You must first enter your email address in order to reset your password." withTitle:@"Reset Password"];
    } else {
        [PFUser requestPasswordResetForEmailInBackground:emailString block:^(BOOL succeeded, NSError *error) {
            [self signInFailedAlert:[NSString stringWithFormat:@"An email was sent to %@ with instructions on resetting your password.", emailString] withTitle:@"Reset Password"];
        }];
    }
}

- (void)signInFailedAlert:(NSString *)alertString withTitle:(NSString *)titleString {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleString message:alertString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) loginSuccesful {
    [VFPush registerPushNotifications];
    [self performSegueWithIdentifier:@"LoginSuccessfulSegue" sender:nil];
}

- (CALayer *)createTextFieldBottomBorder:(UITextField *)textField {
    CALayer *textFieldBorder = [CALayer layer];
    CGFloat borderWidth = 1;
    
    textFieldBorder.borderColor = [UIColor lightGrayColor].CGColor;
    textFieldBorder.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    textFieldBorder.borderWidth = borderWidth;
    
    return textFieldBorder;
}

@end
