//
//  MyAccountVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "MyAccountVC.h"
#import "VFPush.h"

@interface MyAccountVC ()

@property (weak, nonatomic) IBOutlet UITextField *nameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;

@end

@implementation MyAccountVC

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.nameUITextField.text = self.userData[@"name"];
    self.emailAddressUITextField.text = self.userData[@"username"];
}

- (IBAction)saveButtonTap:(UIBarButtonItem *)sender {
    self.userData[@"name"] = self.nameUITextField.text;
    self.userData[@"username"] = self.emailAddressUITextField.text;
    self.userData[@"email"] = self.emailAddressUITextField.text;
    
    if ( ! [self.passwordUITextField.text isEqualToString:@""]) {
        NSLog(@"Saving password also . . .");
        self.userData.password = self.passwordUITextField.text;
    }
    
    [self.userData saveInBackground];
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logoutButtonTap:(id)sender {
    [VFPush deregisterPushNotifications];
    [PFUser logOut];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
