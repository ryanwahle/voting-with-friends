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

@property NSString *localQuestionForPollString;

@end

@implementation AddEditPollVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"cloudDataRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQuestionTextView:) name:@"addEditPoll_questionTextViewChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveQuestionForPoll) name:@"addEditPoll_saveQuestionForPoll" object:nil];
    
    if (self.pollData == nil) {
        // Add a new poll
        VFPoll *newPoll = [VFPoll createPollWithQuestion:@"Touch here to edit your poll question. Answers and friends are added below. May you receive the answer you are looking for!" pollOwner:[PFUser currentUser]];
        
        self.pollData = newPoll;
    }

    
    self.localQuestionForPollString = self.pollData.questionForPoll.copy;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self saveQuestionForPoll];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cloudDataRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addEditPoll_questionTextViewChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addEditPoll_saveQuestionForPoll" object:nil];
}

#pragma mark - Option Switch Logic

- (IBAction)showActivityUISwitchChanged:(UISwitch *)sender {
    self.pollData.shouldDisplayActivity = sender.isOn;
}


- (IBAction)showIndividualAnswerTotalsUISwitchChanged:(UISwitch *)sender {
    self.pollData.shouldDisplayAnswerTotals = sender.isOn;
}

#pragma mark - Question

- (void)updateQuestionTextView:(NSNotification *)notification {
    UITextView *questionTextView = notification.object;
    
    self.localQuestionForPollString = questionTextView.text;

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)saveQuestionForPoll {
    NSLog(@"question to save: %@", self.localQuestionForPollString);
    self.pollData.questionForPoll = self.localQuestionForPollString.copy;
}

#pragma mark - Table view data source

- (void)updateTableView {
    self.tableView.estimatedRowHeight = 88.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Options
        return 1;
    } else if (section == 1) { // Question
        return 1;
    } else if (section == 2) { // Answers
        return self.pollData.possibleAnswersForPoll.count;
    } else if (section == 3) { // Friends
        return self.pollData.friendsOfPoll.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Options
        OptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOptions" forIndexPath:indexPath];
        
        [cell.showActivityUISwitch setOn:self.pollData.shouldDisplayActivity animated:YES];
        [cell.showIndividualAnswerTotalsUISwitch setOn:self.pollData.shouldDisplayAnswerTotals animated:YES];
        
        return cell;
    } else if (indexPath.section == 1) { // Question
        AddEditPollQuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
        
        cell.questionUITextView.text = self.localQuestionForPollString;
        cell.questionUITextView.textColor = [UIColor blackColor];
        
        return cell;
    } else if (indexPath.section == 2) { // Answers
        AddEditPollAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswerKey" forIndexPath:indexPath];

        VFAnswer *answer = self.pollData.possibleAnswersForPoll[indexPath.row];
        cell.answerUILabel.text = answer.answerText;
        
        return cell;
    } else if (indexPath.section == 3) { // Friends
        AddEditPollFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendList" forIndexPath:indexPath];
        VFFriend *friend = self.pollData.friendsOfPoll[indexPath.row];
        
        cell.nameAndEmailUITextView.text = [NSString stringWithFormat:@"%@ (%@)", friend.name, friend.email];
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Options
        return 88;
    } else if (indexPath.section == 1) { // Question
        return self.tableView.rowHeight;
    } else if (indexPath.section == 2) { // Answers
        return 44;
    } else if (indexPath.section == 3) { // Friends
        return 44;
    }
    
    return 44;
}

# pragma mark - Answer Key

- (void)addAnswerKeyToPoll:(NSString *)answerKeyText {
    [self.pollData addPossibleAnswerForPollWithAnswerText:answerKeyText];
}

- (void)deleteAnswerKeyFromPollUsingIndex:(NSInteger)answerKeyIndex {
    [self.pollData removePossibleAnswerFromPollAtIndex:answerKeyIndex];
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

- (IBAction)removeAnswerKeyButtonTouched:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSString *alertMessageText = [NSString stringWithFormat:@"Are you sure you want to delete this answer?"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:alertMessageText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self deleteAnswerKeyFromPollUsingIndex:indexPath.row];
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    [alert addAction:alertCancel];
    
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
            
            PFUser *foundUser = (PFUser *)object;
            
            [self.pollData addFriendToPollByPFUser:foundUser];
            
            //[_pollData addFriend:object.objectId];
            
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

- (IBAction)removeFriendButtonTouched:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSString *alertMessageText = [NSString stringWithFormat:@"Are you sure you want to delete your friend from voting?"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:alertMessageText preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.pollData removeFriendOfPollAtIndex:indexPath.row];
        [alert dismissViewControllerAnimated:YES completion:nil];

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
