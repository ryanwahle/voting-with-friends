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
#import "VoteAnswerCell.h"
#import "HeaderQuestionCell.h"
#import "VoteActivityCell.h"

#import "VFAnswer.h"
#import "VFActivity.h"

@interface VoteVC ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *pollSettingsButton;

@end

@implementation VoteVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.pollData.isPollExpired) {
        self.pollSettingsButton.enabled = NO;
    } else {
        self.pollSettingsButton.enabled = YES;
    }
    
    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView reloadData];
    
    //[[NSNotificationCenter defaultCenter] addObserverForName:@"pollObjectUpdated" object:nil queue:nil usingBlock:^(NSNotification *note) {
    //    [self.tableView reloadData];
    //    NSLog(@"Notification pollObjectUpdated");
    //}];
    
    //[[NSNotificationCenter defaultCenter] addObserverForName:@"cloudDataRefreshed" object:nil queue:nil usingBlock:^(NSNotification *note) {
    //    [self.pollData refreshPoll];
    //    NSLog(@"Notification cloudDataRefreshed");
    //}];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cloudDataRefreshed" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pollObjectUpdated" object:nil];
//}

#pragma mark - Tweet


- (IBAction)tweetButtonTapped:(UIBarButtonItem *)sender {
    
    if (self.pollData.indexOfSelectedAnswerFromCurrentUser == -1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Twitter" message:@"You need to select an answer before you can tweet about it!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        VFAnswer *answerForTweet = self.pollData.possibleAnswersForPoll[self.pollData.indexOfSelectedAnswerFromCurrentUser];
    
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *twitterComposeVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
            NSString *tweetString = [NSString stringWithFormat:@"I just voted for '%@' for a poll created with #VotingWithFriends -- Download now!", answerForTweet.answerText];
        
            [twitterComposeVC setInitialText:tweetString];
        
            [self presentViewController:twitterComposeVC animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Twitter" message:@"Please login to Twitter in the Settings app to share this poll." preferredStyle:UIAlertControllerStyleAlert];
        
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
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
    } else if (section == 1) { // Answer Section
        // There is no header for the answers
    } else if ((section == 2) && self.pollData.shouldDisplayActivity) { // Activity Section
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerActivity"];
    }
    
    return sectionCell.contentView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}


# pragma mark - Answers

- (IBAction)buttonCheckTouched:(UIButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
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
