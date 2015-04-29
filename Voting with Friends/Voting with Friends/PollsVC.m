//
//  PollsVC.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "PollsVC.h"
#import "PollCell.h"
#import "VoteVC.h"
#import "VFPush.h"
#import "AddEditPollVC.h"
#import "MyAccountVC.h"

@interface PollsVC ()

@property NSArray *pollsFromCloud;
@property NSArray *pollsFromCloudExpired;

@end

@implementation PollsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.estimatedRowHeight = 88.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPollDataFromCloud) name:@"cloudDataRefreshed" object:nil];
    
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getPollDataFromCloud) forControlEvents:UIControlEventValueChanged];
    
    [self getPollDataFromCloud];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cloudDataRefreshed" object:nil];
}

- (void)getPollDataFromCloud {
    self.pollsFromCloud = nil;
    self.pollsFromCloudExpired = nil;
    
    PFQuery *pollsWhereCurrentUserIsOwner = [PFQuery queryWithClassName:@"Polls"];
    [pollsWhereCurrentUserIsOwner whereKey:@"pollOwner" equalTo:[PFUser currentUser]];

    PFQuery *pollsWhereCurrentUserIsFriend = [PFQuery queryWithClassName:@"Polls"];
    [pollsWhereCurrentUserIsFriend whereKey:@"friendsOfPoll" equalTo:[PFUser currentUser]];

    PFQuery *pollsForCurrentUser = [PFQuery orQueryWithSubqueries:@[pollsWhereCurrentUserIsOwner, pollsWhereCurrentUserIsFriend]];
    
    [pollsForCurrentUser includeKey:@"pollOwner"];
    [pollsForCurrentUser includeKey:@"friendsOfPoll"];
    [pollsForCurrentUser includeKey:@"pollActivity"];
    [pollsForCurrentUser includeKey:@"possibleAnswersForPoll"];
    [pollsForCurrentUser includeKey:@"possibleAnswersForPoll.votedForByUsers"];
    
    [pollsForCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *pollsArray = [[NSMutableArray alloc] init];
        NSMutableArray *pollsExpiredArray = [[NSMutableArray alloc] init];
    
        for (PFObject *pollObject in objects) {
            VFPoll *vfPoll = [VFPoll createPollWithPFObject:pollObject];
            
            if (vfPoll.isPollExpired) {
                [pollsExpiredArray addObject:vfPoll];
            } else {
                [pollsArray addObject:vfPoll];
            }
        }
        
        [pollsArray sortUsingComparator:^NSComparisonResult(VFPoll *obj1, VFPoll *obj2) {
            return [obj1.expirationDate compare:obj2.expirationDate];
        }];
        
        [pollsExpiredArray sortUsingComparator:^NSComparisonResult(VFPoll *obj1, VFPoll *obj2) {
            return [obj1.expirationDate compare:obj2.expirationDate];
        }];

        
        self.pollsFromCloud = [NSArray arrayWithArray:pollsArray];
        self.pollsFromCloudExpired = [NSArray arrayWithArray:pollsExpiredArray];

        [self updateTableView];
        
        
        // First remove all local notifications currently scheduled
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        // Schedule local notifications for reminders to vote and alerts for polls that expired.
        for (VFPoll *poll in pollsArray) {
            if (poll.expirationDate) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = poll.expirationDate;
                notification.alertBody = [NSString stringWithFormat:@"The poll '%@' by %@ just finished and is now expired. We hope you got what you wanted!", poll.questionForPoll, poll.nameOfPollOwner];
                notification.alertTitle = @"Poll Expired";
                notification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                
                if (poll.indexOfSelectedAnswerFromCurrentUser == -1) {
                    NSDate *hourNoticeExpireDateTime = [poll.expirationDate dateByAddingTimeInterval:-3600];
                    NSDate *nowDateTime = [NSDate date];
                    
                    if ([nowDateTime compare:hourNoticeExpireDateTime] == NSOrderedAscending) {
                        UILocalNotification *notification = [[UILocalNotification alloc] init];
                        notification.fireDate = [poll.expirationDate dateByAddingTimeInterval:-3600];
                        notification.alertBody = [NSString stringWithFormat:@"Vote on the poll '%@' by %@. Poll ends in 1 hour!", poll.questionForPoll, poll.nameOfPollOwner];
                        notification.alertTitle = @"Vote Needed";
                        notification.soundName = UILocalNotificationDefaultSoundName;
                        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                    }
                }
            }
        }
        
        //NSLog(@"\n\nNotfications Scheduled After: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    }];
}

#pragma mark - Table view data source

- (void)updateTableView {
    [self.tableView reloadData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    
    [self.refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    
    if (self.pollsFromCloud.count) {
        sectionCount = 1;
    }
    
    if (self.pollsFromCloudExpired.count) {
        sectionCount = 2;
    }
    
    if (sectionCount) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    } else {
        UIImageView *emptyTable = [[UIImageView alloc] initWithFrame:self.view.bounds];
        emptyTable.image = [UIImage imageNamed:@"EmptyTable"];
        
        self.tableView.backgroundView = emptyTable;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return sectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ((section == 1) && self.pollsFromCloudExpired.count) {
        return @"Poll History";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _pollsFromCloud.count;
    }
    
    return _pollsFromCloudExpired.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VFPoll *pollData;
    
    if (indexPath.section == 0) {
        pollData = _pollsFromCloud[indexPath.row];
    } else {
        pollData = _pollsFromCloudExpired[indexPath.row];
    }

    PollCell *pollCell = [tableView dequeueReusableCellWithIdentifier:@"PollCell" forIndexPath:indexPath];
    
    pollCell.pollQuestion.text = pollData.questionForPoll;
    pollCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", pollData.nameOfPollOwner];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (pollData.isPollExpired) {
        [pollCell.voteButton setTitle: @"Expired - Tap for History" forState: UIControlStateNormal];
        [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:85.0f/255.0f green:98.0f/255.0f blue:112.0f/255.0f alpha:1.0]];
        
        pollCell.expirationLabel.text = [NSString stringWithFormat:@"This poll expired on %@", [dateFormatter stringFromDate:pollData.expirationDate]];
    } else {
        if (pollData.indexOfSelectedAnswerFromCurrentUser > -1) {
            [pollCell.voteButton setTitle: @"Your Vote has Counted" forState: UIControlStateNormal];
            //[pollCell.voteButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
            [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:149.0f/255.0f blue:163.0f/255.0f alpha:1.0]];
        } else {
            [pollCell.voteButton setTitle: @"Tap to Vote" forState: UIControlStateNormal];
            [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:196.0f/255.0f green:77.0f/255.0f blue:88.0f/255.0f alpha:1.0]];
        }
        
        if (pollData.expirationDate) {
            pollCell.expirationLabel.text = [NSString stringWithFormat:@"This poll expires on %@", [dateFormatter stringFromDate:pollData.expirationDate]];
        } else {
            pollCell.expirationLabel.text = @"";
        }
    }
    
    return pollCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Needed for editActions to work
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *returnArray;
    
    VFPoll *swipedPoll;
    
    if (indexPath.section == 0) {
        swipedPoll = self.pollsFromCloud[indexPath.row];
    } else {
        swipedPoll = self.pollsFromCloudExpired[indexPath.row];
    }
    
    if (swipedPoll.isCurrentUserPollOwner) {
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [swipedPoll deletePoll];
        }];
        
        if (swipedPoll.isPollExpired) {
            returnArray = @[deleteAction];
        } else {
            UITableViewRowAction *settingsAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Settings" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                [self performSegueWithIdentifier:@"PollSettings" sender:indexPath];
            }];
            
            returnArray = @[deleteAction, settingsAction];
        }
    } else {
        UITableViewRowAction *notPollOwnerAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Ask Poll Owner\nto Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) { }];
        
        notPollOwnerAction.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0];
        
        returnArray = @[notPollOwnerAction];
    }
    
    return returnArray;
}

#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Vote"]) {
        CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        
        VoteVC *voteVC = [segue destinationViewController];
        
        if (indexPath.section == 0) {
            voteVC.pollData = self.pollsFromCloud[indexPath.row];
        } else {
            voteVC.pollData = self.pollsFromCloudExpired[indexPath.row];
        }
    }
    
    if ([segue.identifier isEqualToString:@"PollSettings"]) {
        NSIndexPath *indexPath = sender;

        AddEditPollVC *destinationVC = [segue destinationViewController];
        
        if (indexPath.section == 0) {
            destinationVC.pollData = self.pollsFromCloud[indexPath.row];
        } else {
            destinationVC.pollData = self.pollsFromCloudExpired[indexPath.row];
        }
    }
    
    if ([segue.identifier isEqualToString:@"MyAccountSegue"]) {
        MyAccountVC *accountVC = [segue destinationViewController];
        accountVC.userData = [PFUser currentUser];
    }
}

@end
