//
//  AddFriendsVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/28/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Parse;

#import "AddFriendsVC.h"
#import "AddNewEmailCell.h"

#import "VFFriend.h"

@interface AddFriendsVC ()
{
    AddNewEmailCell *addNewEmailCell;
}

@end

@implementation AddFriendsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Friends List";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.friendsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self->addNewEmailCell) {
            return self->addNewEmailCell;
        }
        
        self->addNewEmailCell = [tableView dequeueReusableCellWithIdentifier:@"cellAddNewEmail"];
        
        return self->addNewEmailCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellPreviousFriend"];
    PFUser *friend = self.friendsList[indexPath.row];
    
    cell.textLabel.text = friend[@"name"];
    cell.detailTextLabel.text = friend.email;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self addUserToPollSettings:self.friendsList[indexPath.row]];
    }
}

#pragma mark - Add Email

- (void)addUserToPollSettings:(PFUser *)user {
    BOOL shouldAddUserToPoll = YES;
    
    // Make sure friend isn't already added
    for (VFFriend *friend in self.pollFriends) {
        if ([user.objectId isEqualToString:friend.pollFriend.objectId]) {
            shouldAddUserToPoll = NO;
        }
    }
    
    // Make sure you aren't trying to add yourself
    if ([user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        shouldAddUserToPoll = NO;
    }
    
    if (shouldAddUserToPoll) {
        // Add to the new friends array
        [self.pollFriendsToAdd addObject:[VFFriend friendFromPFUser:user]];
    
        // Add to the main friends array holding new and old friends.
        [self.pollFriends addObject:[VFFriend friendFromPFUser:user]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addEmailButtonTapped:(UIButton *)sender {
    NSString *emailString = [self->addNewEmailCell.emailTextField.text.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    PFQuery *userVerify = [PFUser query];
    [userVerify whereKey:@"email" equalTo:emailString.lowercaseString];
    
    [userVerify getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            [self addUserToPollSettings:(PFUser *)object];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Try Different Email Address" message:[NSString stringWithFormat:@"%@ has not signed up with Voting with Friends yet.", emailString] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:alertOK];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
