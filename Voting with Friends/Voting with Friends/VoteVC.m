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

@interface VoteVC ()

@end

@implementation VoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    if (_pollData) {
        NSLog(@"Recieved vote data: (%@)", _pollData.pollQuestion);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 4;
    } else if (section == 2) {
        return 3;
    }
    
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellQuestion" forIndexPath:indexPath];
       
        cell.pollQuestion.text = _pollData.pollQuestion;
        
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAnswer" forIndexPath:indexPath];
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellActivity" forIndexPath:indexPath];
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionCell = nil;
    
    
    if (section == 0) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
    } else if (section == 1) {
        //sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerQuestion"];
    } else if (section == 2) {
        sectionCell = [tableView dequeueReusableCellWithIdentifier:@"headerActivity"];
    }
    
    return sectionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

- (IBAction)buttonCheckTouched:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PollSettings"]) {
        AddEditPollVC *destinationVC = [segue destinationViewController];
        destinationVC.pollData = _pollData;
    }
}


@end
