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

@interface VFPoll : NSObject

@property (readonly) BOOL isCurrentUserPollOwner;
@property BOOL shouldDisplayActivity;
@property BOOL shouldDisplayAnswerTotals;

/* TODO */ @property NSNumber *indexOfSelectedAnswerFromCurrentUser;

@property (readonly) NSString *nameOfPollOwner;
@property NSString *questionForPoll;

@property (readonly) NSArray *possibleAnswersForPoll;
@property (readonly) NSArray *friendsOfPoll;

+ (instancetype)createPollWithQuestion:(NSString *)questionForPoll pollOwner:(PFUser *)pollOwner;

- (void)addFriendToPollByPFUser:(PFUser *)user;
- (void)removeFriendOfPollAtIndex:(NSInteger)index;

- (void)addPossibleAnswerForPollWithAnswer:(VFAnswer *)answer;
- (void)removePossibleAnswerFromPollAtIndex:(NSInteger)index;

@end
