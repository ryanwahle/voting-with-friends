//
//  LoginVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/19/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *loginUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;

@end

@implementation LoginVC

- (void)viewWillAppear:(BOOL)animated {
    // Make some UI changes to the text fields.
    
    _loginUITextField.borderStyle = UITextBorderStyleNone;
    [_loginUITextField.layer addSublayer:[self createTextFieldBottomBorder:_loginUITextField]];
    
    _passwordUITextField.borderStyle = UITextBorderStyleNone;
    [_passwordUITextField.layer addSublayer:[self createTextFieldBottomBorder:_passwordUITextField]];
    
    [_loginUITextField becomeFirstResponder];
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
