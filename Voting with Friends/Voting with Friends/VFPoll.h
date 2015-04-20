//
//  VFPoll.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@class VFAnswer;
@class VFFriend;

@interface VFPoll : NSObject

@property PFObject *pollFromParse;

@property (readonly) BOOL isCurrentUserPollOwner;
@property BOOL shouldDisplayActivity;
@property BOOL shouldDisplayAnswerTotals;
@property NSDate *expirationDate;

@property (readonly) NSInteger indexOfSelectedAnswerFromCurrentUser;

@property (readonly) NSString *nameOfPollOwner;

@property NSString *questionForPoll;

@property (readonly) NSArray *pollActivity;
@property (readonly) NSArray *possibleAnswersForPoll;
@property (readonly) NSArray *friendsOfPoll;

+ (instancetype)createPollForUser:(PFUser *)pollOwner;
+ (instancetype)createPollWithPFObject:(PFObject *)pfObject;

- (void)addAnswerObjectToPoll:(VFAnswer *)answer;
- (void)removeAnswerObjectFromPoll:(VFAnswer *)answer;

- (void)addFriendObjectToPoll:(VFFriend *)friend;
- (void)removeFriendObjectFromPoll:(VFFriend *)friend;

- (void)deletePoll;
- (void)refreshPoll;

- (void)save;

@end
