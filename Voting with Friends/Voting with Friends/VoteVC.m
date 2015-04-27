//
//  VoteVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Social;

#import "VoteVC.h"
#import "QuestionCell.h"
#import "AddEditPollVC.h"
#import "HeaderQuestionCell.h"
#import "AnswerCell.h"
#import "VFAnswer.h"
#import "VFActivity.h"


@implementation VoteVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
}

#pragma mark - Tweet

- (IBAction)shareButtonTapped:(UIBarButtonItem *)sender {
    if (self.pollData.indexOfSelectedAnswerFromCurrentUser == -1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Share" message:@"You need to select an answer before you can share it!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    VFAnswer *answerForShare = self.pollData.possibleAnswersForPoll[self.pollData.indexOfSelectedAnswerFromCurrentUser];
    NSString *shareString = [NSString stringWithFormat:@"I just voted for '%@' for a poll created with #VotingWithFriends -- Download now!", answerForShare.answerText];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Question Section
        return 1;
    }
    
    if (section == 1) { // Answer Section
        return self.pollData.possibleAnswersForPoll.count;
    }
    
    if ((section == 2) && self.pollData.shouldDisplayActivity) { // Activity Section
        return self.pollData.pollActivity.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Question Section
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
       
        cell.pollQuestion.text = self.pollData.questionForPoll;
        
        return cell;
    }
    
    if (indexPath.section == 1) { // Answer Section
        AnswerCell *cell = (AnswerCell *)[tableView dequeueReusableCellWithIdentifier:@"cellAnswer" forIndexPath:indexPath];
        
        if (self.pollData.shouldDisplayAnswerTotals) {
            cell.cellDetailLabel.hidden = NO;
        } else {
            cell.cellDetailLabel.hidden = YES;
        }
        
        VFAnswer *answer = self.pollData.possibleAnswersForPoll[indexPath.row];
        
        if (self.pollData.indexOfSelectedAnswerFromCurrentUser == indexPath.row) {
            cell.cellImageView.image = [UIImage imageNamed:@"AnswerChecked"];
        } else {
            cell.cellImageView.image = [UIImage imageNamed:@"AnswerUnchecked"];
        }
        
        cell.cellTextLabel.text = answer.answerText;
        cell.cellDetailLabel.text = [NSString stringWithFormat:@"%ld votes", (long)answer.totalVotesForPoll];
        
        return cell;
    }
    
    if (indexPath.section == 2) { // Activity Section
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellActivity" forIndexPath:indexPath];
        
        VFActivity *activity = self.pollData.pollActivity[indexPath.row];
        
        cell.detailTextLabel.text = activity.descriptionOfActivity;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

        cell.textLabel.text = [dateFormatter stringFromDate:activity.dateAndTimeOfActivity];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath: %@" , indexPath);
    if (indexPath.section == 1) { // Answer Section
        if (self.pollData.isPollExpired) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Poll Expired" message:@"This poll has expired so you are not allowed to change your vote." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        // Remove the currently selected answer from database
        if (self.pollData.indexOfSelectedAnswerFromCurrentUser != indexPath.row) {
            if (self.pollData.indexOfSelectedAnswerFromCurrentUser != -1) {
                VFAnswer *existingAnswer = self.pollData.possibleAnswersForPoll[self.pollData.indexOfSelectedAnswerFromCurrentUser];
                [existingAnswer removeSelectedAnswerForCurrentUser];
                [existingAnswer save];
            }
            
            VFAnswer *newAnswer = self.pollData.possibleAnswersForPoll[indexPath.row];
            [newAnswer selectAnswerForCurrentUser];
            [newAnswer save];
            
            [self.pollData addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ chose the answer %@", [PFUser currentUser][@"name"], newAnswer.answerText]];
            [self.pollData save];
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    if (section == 0) { // Question Section
        HeaderQuestionCell *headerQuestionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
        
        headerQuestionCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", self.pollData.nameOfPollOwner];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        if (self.pollData.isPollExpired) {
            headerQuestionCell.pollExpirationDate.text = [NSString stringWithFormat:@"This poll expired on %@", [dateFormatter stringFromDate:self.pollData.expirationDate]];
        } else {
            if (self.pollData.expirationDate) {
                headerQuestionCell.pollExpirationDate.text = [NSString stringWithFormat:@"This poll expires on %@", [dateFormatter stringFromDate:self.pollData.expirationDate]];
            } else {
                headerQuestionCell.pollExpirationDate.text = @"";
            }
        }
        
        return headerQuestionCell.contentView;
    }
    
    if (section == 1) { // Answer Section
        // There is no header for the answers
    }
    
    if ((section == 2) && self.pollData.shouldDisplayActivity) { // Activity Section
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerActivity"];
    }
    
    return sectionCell.contentView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}
@end
