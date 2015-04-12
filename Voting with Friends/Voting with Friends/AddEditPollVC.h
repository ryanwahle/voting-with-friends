//
//  AddEditPollVC.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import UIKit;
@import AddressBook;
@import AddressBookUI;

@class VWFPoll;

@interface AddEditPollVC : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property VWFPoll *pollData;

@end
