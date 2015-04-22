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
#import "AddEditPollAnswerCell.h"
#import "AddEditPollFriendCell.h"

#import "VFPoll.h"
#import "VFAnswer.h"
#import "VFFriend.h"

@interface AddEditPollVC ()
{
    NSMutableArray *pollAnswers;
    NSMutableArray *pollAnswersToDelete;
    
    NSMutableArray *pollFriends;
    NSMutableArray *pollFriendsToDelete;
    NSMutableArray *pollFriendsToAdd;
}
@end

@implementation AddEditPollVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self->pollAnswersToDelete = [[NSMutableArray alloc] init];
    self->pollFriendsToDelete = [[NSMutableArray alloc] init];
    self->pollFriendsToAdd = [[NSMutableArray alloc] init];
    
    if (self.pollData) {
        self->pollAnswers = [NSMutableArray arrayWithArray:self.pollData.possibleAnswersForPoll];
        self->pollFriends = [NSMutableArray arrayWithArray:self.pollData.friendsOfPoll];
    } else {
        self.title = @"New Poll";
        self->pollAnswers = [[NSMutableArray alloc] init];
        self->pollFriends = [[NSMutableArray alloc] init];
    }
    
    self.editing = YES;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
    
- (IBAction)saveButton:(UIBarButtonItem *)sender {
    VFPoll *savePoll = nil;
    
    // If no pollData, then this is a new poll we are creating.
    if (self.pollData == nil) {
        savePoll = [VFPoll createPollForUser:[PFUser currentUser]];
    } else {
        savePoll = self.pollData;
    }
    
    // Options
    OptionsCell *optionsCell = (OptionsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    savePoll.shouldDisplayActivity = optionsCell.showActivityUISwitch.isOn;
    savePoll.shouldDisplayAnswerTotals = optionsCell.showIndividualAnswerTotalsUISwitch.isOn;
    savePoll.expirationDate = optionsCell.pollExpirationDate.date;
    
    // Question
    AddEditPollQuestionCell *addEditPollQuestionCell = (AddEditPollQuestionCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    savePoll.questionForPoll = addEditPollQuestionCell.questionUITextView.text;
    
    // Answers :: Remove all the answers the user removed that were already saved in parse and the poll
    for (VFAnswer *answer in self->pollAnswersToDelete) {
        [savePoll removeAnswerObjectFromPoll:answer];
        [answer deleteAnswer];
    }
    
    [savePoll save];
    
    // Answers :: Add to poll if not in poll already and if needed and then save all the answers to parse.
    for (VFAnswer *answer in self->pollAnswers) {
        if (answer.answerFromParse.objectId == nil) {
            [savePoll addAnswerObjectToPoll:answer];
        }
        
        [answer save];
    }
    
    [savePoll save];
    
    // Friends :: Remove all the friends the user removed
    for (VFFriend *friend in self->pollFriendsToDelete) {
        [savePoll removeFriendObjectFromPoll:friend];
    }
    
    [savePoll save];
    
    // Friends :: Add any new friends to the poll
    for (VFFriend *friend in self->pollFriendsToAdd) {
        [savePoll addFriendObjectToPoll:friend];
    }
    
    // Save and return back to previous screen
    [savePoll save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Options
        return 1;
    } else if (section == 1) { // Question
        return 1;
    } else if (section == 2) { // Answers
        return [self->pollAnswers count];
    } else if (section == 3) { // Friends
        return [self->pollFriends count];
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) { // Answers
        return YES;
    } else if (indexPath.section == 3) { // Friends
        return YES;
    }
    
    // Options and Questions can't be deleted
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        [self deleteAnswerKeyFromPollUsingIndex:indexPath.row];
    } else if (indexPath.section == 3) {
        [self deleteFriendFromPollUsingIndex:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Options
        OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOptions" forIndexPath:indexPath];
        
        if (self.pollData) {
            [cell.showActivityUISwitch setOn:self.pollData.shouldDisplayActivity animated:YES];
            [cell.showIndividualAnswerTotalsUISwitch setOn:self.pollData.shouldDisplayAnswerTotals animated:YES];
            
            [cell.pollExpirationDate setDate:self.pollData.expirationDate animated:YES];
        }
        
        return cell;
    } else if (indexPath.section == 1) { // Question
        AddEditPollQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
        
        if (self.pollData) {
            cell.questionUITextView.text = self.pollData.questionForPoll;
            cell.questionUITextView.textColor = [UIColor blackColor];
        }
        
        return cell;
    } else if (indexPath.section == 2) { // Answers
        AddEditPollAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswerKey" forIndexPath:indexPath];

        VFAnswer *answer = self->pollAnswers[indexPath.row];
        cell.answerUILabel.text = answer.answerText;
        
        return cell;
    } else if (indexPath.section == 3) { // Friends
        AddEditPollFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendList" forIndexPath:indexPath];
        
        if (self.pollData) {
            VFFriend *friend = self->pollFriends[indexPath.row];
            cell.nameAndEmailUITextView.text = [NSString stringWithFormat:@"%@ (%@)", friend.name, friend.email];
        }
        
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

    return sectionCell.contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

# pragma mark - Answer Key

- (void)addAnswerKeyToPoll:(NSString *)answerKeyText {
    // Create an VFAnswer object, but don't save it to the cloud in case user cancels
    VFAnswer *answer = [VFAnswer createAnswerUsingString:answerKeyText];
    
    // Add it to the bottom of the answer list array and reload the answer section
    [self->pollAnswers addObject:answer];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteAnswerKeyFromPollUsingIndex:(NSInteger)answerKeyIndex {
    // Get the answer to delete from the answer list array
    VFAnswer *answer = self->pollAnswers[answerKeyIndex];
    
    // If the answer has an answerFromParse object, that means it's saved on the server so we will add it to an array and
    // delete it if user saves.
    if (answer.answerFromParse.objectId) {
        [self->pollAnswersToDelete addObject:answer];
    }
    
    // and remove it from the answer array and reload the answer section
    [self->pollAnswers removeObjectAtIndex:answerKeyIndex];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)addAnswerKeyButtonTouched:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Answer" message:@"Enter a new answer that people can vote for:" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *answerTextField = alert.textFields[0];
        [self addAnswerKeyToPoll:answerTextField.text];
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

# pragma mark - Friends

- (void)addEmailAddressToPoll:(NSString *)email {
    NSLog(@"Verifying %@ is part of Voting with Friends", email);
    
    PFQuery *userVerify = [PFUser query];
    [userVerify whereKey:@"email" equalTo:email.lowercaseString];
    
    [userVerify getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            NSLog(@"Found email address");
            
            // Add to the new friends array
            [self->pollFriendsToAdd addObject:[VFFriend friendFromPFUser:(PFUser *)object]];
            
            // Add to the main friends array holding new and old friends.
            [self->pollFriends addObject:[VFFriend friendFromPFUser:(PFUser *)object]];
            
            
            // Reload friends section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Signed Up" message:[NSString stringWithFormat:@"%@ has not signed up with Voting with Friends yet.", email] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:alertOK];
            
            [self presentViewController:alert animated:YES completion:nil];

        }
    }];
}

- (void)deleteFriendFromPollUsingIndex:(NSInteger)friendIndex {
    // Get the friend to delete from the poll
    VFFriend *friend = self->pollFriends[friendIndex];
    
    // Add to the delete array
    [self->pollFriendsToDelete addObject:friend];
    
    // Remove it from the main friends array
    [self->pollFriends removeObject:friend];
    
    // Reload the friends section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef emails = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(emails, identifier);
    
    NSString *selectedEmail = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, index));
    
    CFRelease(emails);

    [self addEmailAddressToPoll:selectedEmail];
}

- (void)getManualEmailAddress {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add E-Mail Address" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Add E-Mail" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *emailAddressTextField = alert.textFields[0];
        [self addEmailAddressToPoll:emailAddressTextField.text];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    [alert addAction:alertCancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Tap to enter e-mail address";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];

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
        [self getManualEmailAddress];
        [alert dismissViewControllerAnimated:YES completion:^{
            [self getManualEmailAddress];
        }];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertContacts];
    [alert addAction:alertEmailAddress];
    [alert addAction:alertCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


@end
