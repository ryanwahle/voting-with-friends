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

@interface PollsVC ()

@property NSArray *pollsFromCloud;

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
    
        for (PFObject *pollObject in objects) {
            [pollsArray addObject:[VFPoll createPollWithPFObject:pollObject]];
        }
        
        [pollsArray sortUsingComparator:^NSComparisonResult(VFPoll *obj1, VFPoll *obj2) {
            return [obj1.expirationDate compare:obj2.expirationDate];
        }];

        
        self.pollsFromCloud = [NSArray arrayWithArray:pollsArray];

        [self updateTableView];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pollsFromCloud.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VFPoll *pollData = _pollsFromCloud[indexPath.row];

    PollCell *pollCell = [tableView dequeueReusableCellWithIdentifier:@"PollCell" forIndexPath:indexPath];
    
    pollCell.pollQuestion.text = pollData.questionForPoll;
    pollCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", pollData.nameOfPollOwner];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (pollData.isPollExpired) {
        [pollCell.voteButton setTitle: @"Expired - Tap for History" forState: UIControlStateNormal];
        [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
        
        pollCell.expirationLabel.text = [NSString stringWithFormat:@"This poll expired on %@", [dateFormatter stringFromDate:pollData.expirationDate]];
    } else {
        if (pollData.indexOfSelectedAnswerFromCurrentUser > -1) {
            [pollCell.voteButton setTitle: @"Your Vote Has Counted" forState: UIControlStateNormal];
            [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
        } else {
            [pollCell.voteButton setTitle: @"Tap to Vote" forState: UIControlStateNormal];
            [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:192.0f/255.0f green:57.0f/255.0f blue:43.0f/255.0f alpha:1.0]];
        }
        
        if (pollData.expirationDate) {
            pollCell.expirationLabel.text = [NSString stringWithFormat:@"This poll expires on %@", [dateFormatter stringFromDate:pollData.expirationDate]];
        } else {
            pollCell.expirationLabel.text = @"";
        }
    }
    
    return pollCell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {    
    if ([segue.identifier isEqualToString:@"Vote"]) {
        CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        
        VoteVC *voteVC = [segue destinationViewController];
        voteVC.pollData = _pollsFromCloud[indexPath.row];
  
        if (voteVC.pollData.isCurrentUserPollOwner) {
            voteVC.hidesBottomBarWhenPushed = NO;
        } else {
            voteVC.hidesBottomBarWhenPushed = YES;
        }
    }
}


- (IBAction)logoutButtonTap:(id)sender {
    [VFPush deregisterPushNotifications];
    [PFUser logOut];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
