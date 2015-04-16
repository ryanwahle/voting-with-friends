//
//  VoteVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VoteVC.h"
#import "QuestionCell.h"
#import "AddEditPollVC.h"
#import "VoteAnswerCell.h"
#import "HeaderQuestionCell.h"
#import "VoteActivityCell.h"

#import "VFAnswer.h"
#import "VFActivity.h"

@interface VoteVC ()

@end

@implementation VoteVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"pollObjectUpdated" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"cloudDataRefreshed" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.pollData refreshPoll];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cloudDataRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pollObjectUpdated" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Question Section
        return 1;
    } else if (section == 1) { // Answer Section
        return self.pollData.possibleAnswersForPoll.count;
    } else if ((section == 2) && self.pollData.shouldDisplayActivity) { // Activity Section
        return self.pollData.pollActivity.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Question Section
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
       
        cell.pollQuestion.text = self.pollData.questionForPoll;
        
        return cell;
    } else if (indexPath.section == 1) { // Answer Section
        VoteAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswer" forIndexPath:indexPath];
        
        if (self.pollData.shouldDisplayAnswerTotals) {
            cell.totalVotesUILabel.hidden = NO;
        } else {
            cell.totalVotesUILabel.hidden = YES;
        }
        
        VFAnswer *answer = self.pollData.possibleAnswersForPoll[indexPath.row];
 
        cell.totalVotesUILabel.text = [NSString stringWithFormat:@"%ld votes", (long)answer.totalVotesForPoll];
        cell.answerUILabel.text = answer.answerText;
        
        if (self.pollData.indexOfSelectedAnswerFromCurrentUser == indexPath.row) {
            cell.selectedVoteButton.selected = YES;
        } else {
            cell.selectedVoteButton.selected = NO;
        }
        
        return cell;
    } else if (indexPath.section == 2) { // Activity Section
        VoteActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellActivity" forIndexPath:indexPath];
        
        VFActivity *activity = self.pollData.pollActivity[indexPath.row];
        
        cell.labelActivityDescription.text = activity.descriptionOfActivity;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

        cell.labelDateTime.text = [dateFormatter stringFromDate:activity.dateAndTimeOfActivity];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    if (section == 0) { // Question Section
        HeaderQuestionCell *headerQuestionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
        
        headerQuestionCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", self.pollData.nameOfPollOwner];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        headerQuestionCell.pollExpirationDate.text = [NSString stringWithFormat:@"This poll expires on %@", [dateFormatter stringFromDate:self.pollData.expirationDate]];
        
        return headerQuestionCell;
    } else if (section == 1) { // Answer Section
        // There is no header for the answers
    } else if ((section == 2) && self.pollData.shouldDisplayActivity) { // Activity Section
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerActivity"];
    }
    
    return sectionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

# pragma mark - Answers

- (IBAction)buttonCheckTouched:(UIButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    // Remove the currently selected answer from database
    if (self.pollData.indexOfSelectedAnswerFromCurrentUser != indexPath.row) {
        if (self.pollData.indexOfSelectedAnswerFromCurrentUser != -1) {
            VFAnswer *existingAnswer = self.pollData.possibleAnswersForPoll[self.pollData.indexOfSelectedAnswerFromCurrentUser];
            [existingAnswer removeSelectedAnswerForCurrentUser];
        }
        
        VFAnswer *newAnswer = self.pollData.possibleAnswersForPoll[indexPath.row];
        [newAnswer selectAnswerForCurrentUser];
    }
}

#pragma mark - Delete Poll

- (IBAction)deletePollButtonTouched:(UIBarButtonItem *)sender {
    [self.pollData deletePoll];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PollSettings"]) {
        AddEditPollVC *destinationVC = [segue destinationViewController];
        destinationVC.pollData = self.pollData;
    }
}


@end
