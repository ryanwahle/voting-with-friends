//
//  HeaderQuestionCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/5/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import UIKit;

@interface HeaderQuestionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *personsNameWhoCreatedPoll;
@property (weak, nonatomic) IBOutlet UILabel *pollExpirationDate;

@end
