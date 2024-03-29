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
#import "AddEditPollFriendCell.h"
#import "AddFriendsVC.h"

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
    
    NSArray *currentUsersFriendsList;
    
    AddEditPollQuestionCell *addEditPollQuestionCell;
    OptionsCell *optionsCell;
}

@end


@implementation AddEditPollVC

// Setup all the temporary arrays to store data.
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
    
    self->currentUsersFriendsList = [PFUser currentUser][@"friendsList"];
    for (PFUser *user in self->currentUsersFriendsList) {
        [user fetchIfNeededInBackground];
    }
    
    self.editing = YES;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)hideKeyboard:(UITapGestureRecognizer *)sender {
    [self.tableView endEditing:YES];
}

// The user wants to save the poll settings, so update data from the textfields and also add/remove friends
// and answers to/from the parse database.
- (IBAction)saveButton:(UIBarButtonItem *)sender {
    VFPoll *savePoll = nil;
    
    // If no pollData, then this is a new poll we are creating.
    if ( ! self.pollData) {
        savePoll = [VFPoll createPollForUser:[PFUser currentUser]];
    } else {
        savePoll = self.pollData;
    }
    
    // Options
    savePoll.shouldDisplayActivity = self->optionsCell.showActivityUISwitch.isOn;
    savePoll.shouldDisplayAnswerTotals = self->optionsCell.showIndividualAnswerTotalsUISwitch.isOn;
    
    if (self->optionsCell.allowPollToExpireUISwitch.isOn) {
        if ( ! [self->optionsCell.pollExpirationDate.date isEqualToDate:savePoll.expirationDate]) {
            [savePoll addActivityToPollWithDescription:[NSString stringWithFormat:@"Expiration date was changed."]];
        }
        
        savePoll.expirationDate = self->optionsCell.pollExpirationDate.date;
    } else {
        if (savePoll.expirationDate) {
            [savePoll addActivityToPollWithDescription:@"The expiration date was removed."];
        }
        
        savePoll.expirationDate = nil;
    }
    
    // Question
    if ( ! [savePoll.questionForPoll isEqualToString:self->addEditPollQuestionCell.questionUITextView.text]) {
        [savePoll addActivityToPollWithDescription:@"The poll question was changed."];
        savePoll.questionForPoll = self->addEditPollQuestionCell.questionUITextView.text;
    }
    
    // Answers :: Remove all the answers the user removed that were already saved in parse and the poll
    for (VFAnswer *answer in self->pollAnswersToDelete) {
        //[answer deleteAnswer];
        [savePoll removeAnswerObjectFromPoll:answer];
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
    
    // Friends :: Add any new friends to the poll and add friend to current users friendsList
    for (VFFriend *friend in self->pollFriendsToAdd) {
        [savePoll addFriendObjectToPoll:friend];
        
        [[PFUser currentUser] addUniqueObject:friend.pollFriend forKey:@"friendsList"];
        [[PFUser currentUser] saveInBackground];
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
    if (section == VFSettingsSectionOptions) { // Options
        return 1;
    } else if (section == VFSettingsSectionQuestion) { // Question
        return 1;
    } else if (section == VFSettingsSectionAnswerKey) { // Answers
        return [self->pollAnswers count];
    } else if (section == VFSettingsSectionFriendsList) { // Friends
        return [self->pollFriends count];
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VFSettingsSectionAnswerKey) { // Answers
        return YES;
    } else if (indexPath.section == VFSettingsSectionFriendsList) { // Friends
        return YES;
    }
    
    // Options and Questions can't be deleted
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VFSettingsSectionAnswerKey) {
        [self deleteAnswerKeyFromPollUsingIndex:indexPath.row];
    } else if (indexPath.section == VFSettingsSectionFriendsList) {
        [self deleteFriendFromPollUsingIndex:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VFSettingsSectionOptions) { // Options
        if (self->optionsCell) {
            return self->optionsCell;
        }
        
        self->optionsCell = [tableView dequeueReusableCellWithIdentifier:@"cellOptions"];
        
        if (self.pollData) {
            [self->optionsCell.showActivityUISwitch setOn:self.pollData.shouldDisplayActivity animated:YES];
            [self->optionsCell.showIndividualAnswerTotalsUISwitch setOn:self.pollData.shouldDisplayAnswerTotals animated:YES];
            
            if (self.pollData.expirationDate) {
                [self->optionsCell.allowPollToExpireUISwitch setOn:YES animated:YES];
                [self->optionsCell.pollExpirationDate setDate:self.pollData.expirationDate animated:YES];
            } else {
                [self->optionsCell.allowPollToExpireUISwitch setOn:NO animated:NO];
                [self->optionsCell allowPollToExpireUISwitchTap:nil];
            }
        } else {
            [self->optionsCell.allowPollToExpireUISwitch setOn:NO animated:NO];
            [self->optionsCell allowPollToExpireUISwitchTap:nil];
        }
        
        return self->optionsCell;
    }
    
    if (indexPath.section == VFSettingsSectionQuestion) { // Question
        if (self->addEditPollQuestionCell) {
            return self->addEditPollQuestionCell;
        }
        
        self->addEditPollQuestionCell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion"];
        
        if (self.pollData) {
            self->addEditPollQuestionCell.questionUITextView.text = self.pollData.questionForPoll;
            self->addEditPollQuestionCell.questionUITextView.textColor = [UIColor blackColor];
        }
        
        return self->addEditPollQuestionCell;
    }
    
    if (indexPath.section == VFSettingsSectionAnswerKey) { // Answers
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswerKey" forIndexPath:indexPath];

        VFAnswer *answer = self->pollAnswers[indexPath.row];
        cell.textLabel.text = answer.answerText;
        
        return cell;
    }
    
    if (indexPath.section == VFSettingsSectionFriendsList) { // Friends
        AddEditPollFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFriendList" forIndexPath:indexPath];
        
        VFFriend *friend = self->pollFriends[indexPath.row];
        cell.nameAndEmailUITextView.text = [NSString stringWithFormat:@"%@ (%@)", friend.name, friend.email];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    if (section == VFSettingsSectionOptions) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerOptions"];
    } else if (section == VFSettingsSectionQuestion) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
    } else if (section == VFSettingsSectionAnswerKey) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerAnswerKey"];
    } else if (section == VFSettingsSectionFriendsList) {
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

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VFSettingsSectionAnswerKey] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VFSettingsSectionAnswerKey] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

# pragma mark - Friends

- (void)deleteFriendFromPollUsingIndex:(NSInteger)friendIndex {
    // Get the friend to delete from the poll
    VFFriend *friend = self->pollFriends[friendIndex];
    
    // Add to the delete array
    [self->pollFriendsToDelete addObject:friend];
    
    // Remove it from the main friends array
    [self->pollFriends removeObject:friend];
    
    // Reload the friends section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:VFSettingsSectionFriendsList] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddFriendsSegue"]) {
        AddFriendsVC *addFriendsVC = [segue destinationViewController];
        
        addFriendsVC.friendsList= self->currentUsersFriendsList;
        addFriendsVC.pollFriends = self->pollFriends;
        addFriendsVC.pollFriendsToAdd = self->pollFriendsToAdd;
    }
}


@end
