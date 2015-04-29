//
//  AddEditPollVC.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import UIKit;

@class VFPoll;

@interface AddEditPollVC : UITableViewController

@property (weak) VFPoll *pollData;

typedef NS_ENUM(NSInteger, VFSettingsSection) {
    VFSettingsSectionQuestion,
    VFSettingsSectionAnswerKey,
    VFSettingsSectionFriendsList,
    VFSettingsSectionOptions
};

@end
