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

// Populate textfields with user data
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.nameUITextField.text = self.userData[@"name"];
    self.emailAddressUITextField.text = self.userData[@"username"];
}

// Validate user input and always save email and name. Only save password if user entered text into the password textfield.
- (IBAction)saveButtonTap:(UIBarButtonItem *)sender {
    NSString *emailString = [self.emailAddressUITextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *passwordString = [self.passwordUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nameString = [self.nameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ( ! emailString.length) {
        [self showAlert:@"You must enter an email address."];
        return;
    } else if ( ! nameString.length) {
        [self showAlert:@"You must enter your name."];
        return;
    }

    
    self.userData[@"email"] = emailString;
    
    [self.userData saveInBackgroundWithBlock:^(BOOL successful, NSError *parseError) {
        if (!successful) {
            [self showAlert:@"You must enter a correct email address."];
            return;
        }
        
        self.userData[@"name"] = nameString;
        self.userData[@"username"] = emailString;
        
        if ( ! [passwordString isEqualToString:@""]) {
            NSLog(@"Saving password also . . .");
            self.userData.password = passwordString;
        }

        [self.userData saveInBackground];
            
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (IBAction)cancelButtonTap:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// User wants to log out, so deregister the push notifications for this user to this device.
- (IBAction)logoutButtonTap:(id)sender {
    [VFPush deregisterPushNotifications];
    [PFUser logOut];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// Alert box
- (void)showAlert:(NSString *)alertString {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Account Update Failed" message:alertString preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
