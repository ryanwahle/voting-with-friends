//
//  OptionsCell.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import UIKit;

@interface OptionsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *showActivityUISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *showIndividualAnswerTotalsUISwitch;

@property (weak, nonatomic) IBOutlet UILabel *pollExpirationLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *pollExpirationDate;

@property (weak, nonatomic) IBOutlet UISwitch *allowPollToExpireUISwitch;

- (IBAction)allowPollToExpireUISwitchTap:(id)sender;

@end
