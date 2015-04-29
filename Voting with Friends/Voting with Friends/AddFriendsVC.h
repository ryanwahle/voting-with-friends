//
//  AddFriendsVC.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/28/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VFPoll;

@interface AddFriendsVC : UITableViewController

@property NSMutableArray *pollFriends;
@property NSMutableArray *pollFriendsToAdd;
@property NSArray *friendsList;

@end
