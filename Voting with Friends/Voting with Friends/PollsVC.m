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

#import "VWFUserAnswerForPoll.h"

@interface PollsVC ()

@property NSArray *pollsFromCloud;

@end

@implementation PollsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.estimatedRowHeight = 88.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"cloudDataUpdated" object:nil];
    
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getPollDataFromCloud) forControlEvents:UIControlEventValueChanged];
    
    _pollsFromCloud = @[];
    [self getPollDataFromCloud];
}

- (void)getPollDataFromCloud {
    
    NSLog(@"(getPollDataFromCloud) Getting data from cloud.");
    
    PFQuery *pollsForCurrentUserQuery = [VWFUserAnswerForPoll query];
    [pollsForCurrentUserQuery whereKey:@"userPointer" equalTo:[PFUser objectWithoutDataWithObjectId:[PFUser currentUser].objectId]];
    [pollsForCurrentUserQuery includeKey:@"pollPointer"];
    [pollsForCurrentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *pollsArray = [[NSMutableArray alloc] init];
        
        for (VWFUserAnswerForPoll *pollsForCurrentUser in objects) {
            [pollsArray addObject:pollsForCurrentUser.pollPointer];
        }
        
        _pollsFromCloud = [NSArray arrayWithArray:pollsArray];
        for (VWFPoll *poll in _pollsFromCloud) {
            [poll refreshCloudDataAndPostNotification:@"cloudDataUpdated"];
        }
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
    VWFPoll *pollData = _pollsFromCloud[indexPath.row];
    
    PollCell *pollCell = [tableView dequeueReusableCellWithIdentifier:@"PollCell" forIndexPath:indexPath];
    
    pollCell.pollQuestion.text = pollData.pollQuestion;
    pollCell.personsNameWhoCreatedPoll.text = [NSString stringWithFormat:@"%@ asks . . .", pollData.nameOfCreatedByUser];
    
    if (pollData.currentSelectedAnswer.answerPointer) {
        [pollCell.voteButton setTitle: @"Vote Saved" forState: UIControlStateNormal];
    } else {
        [pollCell.voteButton setTitle: @"Please Vote" forState: UIControlStateNormal];
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
        
        if ([[PFUser currentUser].objectId isEqualToString:voteVC.pollData.createdByUserPointer.objectId]) {
            voteVC.hidesBottomBarWhenPushed = NO;
        } else {
            voteVC.hidesBottomBarWhenPushed = YES;
        }
    }
}


- (IBAction)logoutButtonTap:(id)sender {
    [PFUser logOut];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
