//
//  AddNewEmailCell.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/28/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "AddNewEmailCell.h"

@implementation AddNewEmailCell

- (IBAction)emailTextfieldEditingChanged:(UITextField *)sender {
    NSString *emailString = [sender.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (emailString.length) {
        self.addButton.enabled = YES;
    } else {
        self.addButton.enabled = NO;
    }
}

@end
