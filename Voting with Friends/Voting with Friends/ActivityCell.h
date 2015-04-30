//
//  ActivityCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/29/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;

@end
