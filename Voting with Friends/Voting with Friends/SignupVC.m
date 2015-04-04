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

- (void)viewWillAppear:(BOOL)animated {
    // Make some UI changes to the text fields.
    
    _nameUITextField.borderStyle = UITextBorderStyleNone;
    [_nameUITextField.layer addSublayer:[self createTextFieldBottomBorder:_nameUITextField]];
    
    _emailUITextField.borderStyle = UITextBorderStyleNone;
    [_emailUITextField.layer addSublayer:[self createTextFieldBottomBorder:_emailUITextField]];
    
    _passwordUITextField.borderStyle = UITextBorderStyleNone;
    [_passwordUITextField.layer addSublayer:[self createTextFieldBottomBorder:_passwordUITextField]];
    
    [_nameUITextField becomeFirstResponder];
}

- (CALayer *)createTextFieldBottomBorder:(UITextField *)textField {
    CALayer *textFieldBorder = [CALayer layer];
    CGFloat borderWidth = 1;
    
    textFieldBorder.borderColor = [UIColor lightGrayColor].CGColor;
    textFieldBorder.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    textFieldBorder.borderWidth = borderWidth;
    
    return textFieldBorder;
}

- (void) signupNewUser {
    PFUser *newUser = [PFUser user];
    
    newUser.username = _emailUITextField.text;
    newUser.password = _passwordUITextField.text;
    newUser.email = _emailUITextField.text;
    
    newUser[@"name"] = _nameUITextField.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"SignupButtonSegue" sender:nil];
        } else {
            // Error
        }
    }];
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SignupButtonSegue"]) {
        [self signupNewUser];
        return NO;
    }
    
    return YES;
}

@end
