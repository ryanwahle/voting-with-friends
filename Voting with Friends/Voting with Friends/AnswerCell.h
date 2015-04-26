//
//  AnswerCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/26/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailLabel;

@end
