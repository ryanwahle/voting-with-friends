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

@interface PollsVC ()

@property NSArray *pollsFromCloud;

@end

@implementation PollsVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.estimatedRowHeight = 88.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"cloudDataUpdated" object:nil];
    
    _pollsFromCloud = @[];
    
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(getPollDataFromCloud) forControlEvents:UIControlEventValueChanged];
    
    [self getPollDataFromCloud];
}

- (void)getPollDataFromCloud {
    
    NSLog(@"(getPollDataFromCloud) Getting data from cloud.");
    
    PFQuery *queryForPolls = [VWFPoll query];
    [queryForPolls findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"(viewDidLoad) Error: %@ %@", error, [error userInfo]);
        } else {
            NSLog(@"(viewDidLoad) Found %lu polls in the cloud.", objects.count);
            _pollsFromCloud = objects;
            
            for (VWFPoll *poll in _pollsFromCloud) {
                [poll refreshCloudDataAndPostNotification:@"cloudDataUpdated"];
            }
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
    
    NSLog(@"refreshing tableview");
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
    
    if (pollData.currentSelectedAnswer) {
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
    }
}



@end
