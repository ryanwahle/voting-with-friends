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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"pollsListCloudDataUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPollDataFromCloud) name:@"refreshPollsList" object:nil];
    
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getPollDataFromCloud) forControlEvents:UIControlEventValueChanged];
    
    _pollsFromCloud = @[];
    [self getPollDataFromCloud];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pollsListCloudDataUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPollsList" object:nil];
}

- (void)getPollDataFromCloud {
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
        
        self.pollsFromCloud = [NSArray arrayWithArray:pollsArray];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"pollsListCloudDataUpdated" object:nil];
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

    if (pollData.indexOfSelectedAnswerFromCurrentUser > -1) {
        [pollCell.voteButton setTitle: @"Vote Saved" forState: UIControlStateNormal];
        //[pollCell.voteButton setTitleColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
        [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0]];
    } else {
        [pollCell.voteButton setTitle: @"Please Vote" forState: UIControlStateNormal];
        //[pollCell.voteButton setTitleColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
        [pollCell.voteButton setBackgroundColor:[UIColor colorWithRed:192.0f/255.0f green:57.0f/255.0f blue:43.0f/255.0f alpha:1.0]];
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
