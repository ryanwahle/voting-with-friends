//
//  VWFPoll.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "VWFAnswers.h"
#import "VWFUserAnswerForPoll.h"

@class VWFUserAnswerForPoll;

@interface VWFPoll : PFObject <PFSubclassing>

@property NSString *pollQuestion;
@property NSArray *pollAnswerKeys;
@property NSArray *pollFriends;
@property VWFUserAnswerForPoll *currentSelectedAnswer;

@property PFUser *createdByUserPointer;
@property NSString *nameOfCreatedByUser;

@property BOOL showActivity;
@property BOOL showIndividualAnswerTotals;

+ (NSString *)parseClassName;

- (void)refreshCloudDataAndPostNotification:(NSString *)notificationString;
- (void)deletePoll;
- (void)addFriend:(NSString *)objectIdForPFUser;

@end
