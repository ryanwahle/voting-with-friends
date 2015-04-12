//
//  PollCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import UIKit;

@interface PollCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *personsNameWhoCreatedPoll;
@property (weak, nonatomic) IBOutlet UILabel *pollQuestion;
@property (weak, nonatomic) IBOutlet UIButton *voteButton;

@end
