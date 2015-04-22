//
//  OptionsCell.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "OptionsCell.h"

@implementation OptionsCell

- (IBAction)allowPollToExpireUISwitchTap:(id)sender {
    self.pollExpirationLabel.hidden = !self.pollExpirationLabel.hidden;
    self.pollExpirationDate.hidden = !self.pollExpirationDate.hidden;
}

@end
