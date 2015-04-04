//
//  VoteAnswerCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/2/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoteAnswerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *totalVotesUILabel;
@property (weak, nonatomic) IBOutlet UILabel *answerUILabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedVoteButton;

@end
