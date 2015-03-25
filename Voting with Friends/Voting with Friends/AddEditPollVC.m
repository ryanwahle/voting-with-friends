//
//  AddEditPollVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "AddEditPollVC.h"
#import "OptionsCell.h"
#import "AddEditPollQuestionCell.h"

@interface AddEditPollVC ()

@end

@implementation AddEditPollVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_pollData) {
        NSLog(@"Recieved vote data: (%@)", _pollData.pollQuestion);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 5;
    } else if (section == 3) {
        return 3;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOptions" forIndexPath:indexPath];
        
        [cell.showActivityUISwitch setOn:_pollData.showActivity animated:YES];
        [cell.showIndividualAnswerTotalsUISwitch setOn:_pollData.showIndividualAnswerTotals animated:YES];
        
        NSLog(@"%d:%d", _pollData.showActivity, _pollData.showIndividualAnswerTotals);
        
        return cell;
    } else if (indexPath.section == 1) {
        AddEditPollQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
        
        cell.questionUITextField.text = _pollData.pollQuestion;
        
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswerKey" forIndexPath:indexPath];
        return cell;
    } else if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendList" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    if (section == 0) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerOptions"];
    } else if (section == 1) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
    } else if (section == 2) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerAnswerKey"];
    } else if (section == 3) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerFriendList"];
    }

    return sectionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 88;
    } else if (indexPath.section == 1) {
        return 88;
    } else if (indexPath.section == 2) {
        return 44;
    } else if (indexPath.section == 3) {
        return 44;
    }
    
    return 44;
}



- (IBAction)addAnswerKeyButtonTouched:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Answer" message:@"Enter a new answer that people can vote for:" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    [alert addAction:alertCancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Type your answer here";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    NSLog(@"Selected user");
    
    NSString *selectedFirstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *selectedLastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
    ABMultiValueRef emails = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(emails, identifier);
    
    NSString *selectedEmail = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, index));
    
    CFRelease(emails);
    
    NSLog(@"%@ - name: %@ %@ / email selected: %@", ABPersonEmailAddressesProperty, selectedFirstName, selectedLastName, selectedEmail);

    
}

- (IBAction)addFriendButtonTouched:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Friend to Vote" message:@"How would you like to enter the email address?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alertContacts = [UIAlertAction actionWithTitle:@"From Contacts" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        ABPeoplePickerNavigationController *emailPickerFromContacts = [[ABPeoplePickerNavigationController alloc] init];
        emailPickerFromContacts.peoplePickerDelegate = self;
        
        emailPickerFromContacts.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"emailAddresses.@count > 0"];
        emailPickerFromContacts.displayedProperties = @[@(kABPersonEmailProperty)];
        
        [self presentViewController:emailPickerFromContacts animated:YES completion:nil];
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertEmailAddress = [UIAlertAction actionWithTitle:@"Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertContacts];
    [alert addAction:alertEmailAddress];
    [alert addAction:alertCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)removeAnswerKeyButtonTouched:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSString *alertMessageText = [NSString stringWithFormat:@"Are you sure you want to delete the answer (row: %ld) ?", indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:alertMessageText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    [alert addAction:alertCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)removeFriendButtonTouched:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSString *alertMessageText = [NSString stringWithFormat:@"Are you sure you want to delete your friend (row: %ld) from voting?", indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:alertMessageText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    [alert addAction:alertCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
