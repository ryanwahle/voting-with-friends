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

#import "VWFAnswers.h"
#import "VWFUserAnswerForPoll.h"

@interface VoteVC ()

@end

@implementation VoteVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"vote_cloudDataUpdated" object:nil];
    
    [_pollData refreshCloudDataAndPostNotification:@"vote_cloudDataUpdated"];
}

#pragma mark - Table view data source

- (void)updateTableView {
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // Question Section
        return 1;
    } else if (section == 1) { // Answer Section
        return _pollData.pollAnswerKeys.count;
    } else if ((section == 2) && _pollData.showActivity) { // Activity Section
        return 3;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // Question Section
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
       
        cell.pollQuestion.text = _pollData.pollQuestion;
        
        return cell;
    } else if (indexPath.section == 1) { // Answer Section
        VoteAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswer" forIndexPath:indexPath];
        
        if (_pollData.showIndividualAnswerTotals) {
            cell.totalVotesUILabel.hidden = NO;
        } else {
            cell.totalVotesUILabel.hidden = YES;
        }
        
        cell.answerUILabel.text = ((VWFAnswers *)_pollData.pollAnswerKeys[indexPath.row]).pollAnswer;
        
        if ([_pollData.currentSelectedAnswer.answerPointer.objectId isEqualToString:((VWFAnswers *)_pollData.pollAnswerKeys[indexPath.row]).objectId]) {
            cell.selectedVoteButton.selected = YES;
        } else {
            cell.selectedVoteButton.selected = NO;
        }
        
        cell.totalVotesUILabel.text = [NSString stringWithFormat:@"%ld votes", (long)((VWFAnswers *)_pollData.pollAnswerKeys[indexPath.row]).totalNumberOfVotes];
        
        return cell;
    } else if (indexPath.section == 2) { // Activity Section
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellActivity" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    if (section == 0) { // Question Section
        HeaderQuestionCell *headerQuestionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
        
        headerQuestionCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", _pollData.nameOfCreatedByUser];
        
        return headerQuestionCell;
    } else if (section == 1) { // Answer Section
        // There is no header for the answers
    } else if ((section == 2) && _pollData.showActivity) { // Activity Section
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
    if (_pollData.currentSelectedAnswer) {
        [_pollData.currentSelectedAnswer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            // Add newly selected answer to database
            [self saveSelectedAnswer:indexPath.row];
        }];
    } else {
        [self saveSelectedAnswer:indexPath.row];
    }
}

- (void)saveSelectedAnswer:(NSInteger) row {
    VWFUserAnswerForPoll *currentAnswer = [VWFUserAnswerForPoll object];
    currentAnswer.pollPointer = [VWFPoll objectWithoutDataWithObjectId:_pollData.objectId];
    currentAnswer.answerPointer = [VWFAnswers objectWithoutDataWithObjectId:((VWFAnswers *)_pollData.pollAnswerKeys[row]).objectId];
    currentAnswer.userPointer = [PFUser objectWithoutDataWithObjectId:[PFUser currentUser].objectId];
    
    [currentAnswer saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Refresh the data from the database and update tableview
            [_pollData refreshCloudDataAndPostNotification:@"vote_cloudDataUpdated"];
        }
    }];
}

#pragma mark - Delete Poll

- (IBAction)deletePollButtonTouched:(UIBarButtonItem *)sender {
    [_pollData deletePoll];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PollSettings"]) {
        AddEditPollVC *destinationVC = [segue destinationViewController];
        destinationVC.pollData = _pollData;
    }
}


@end
