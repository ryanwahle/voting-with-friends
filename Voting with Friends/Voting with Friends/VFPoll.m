//
//  VFPoll.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VFPoll.h"
#import "VFFriend.h"
#import "VFAnswer.h"
#import "VFPush.h"
#import "VFActivity.h"

@interface VFPoll ()

@end


@implementation VFPoll

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)createPollWithPFObject:(PFObject *)object {
    VFPoll *poll = [[VFPoll alloc] init];
    
    poll.pollFromParse = object;
    
    return poll;
}

+ (instancetype)createPollWithQuestion:(NSString *)questionForPoll pollOwner:(PFUser *)pollOwner {
    VFPoll *poll = [[VFPoll alloc] init];
    
    poll.pollFromParse = [PFObject objectWithClassName:@"Polls"];
    [poll save];
    
    poll.questionForPoll = questionForPoll;
    poll.pollOwner = pollOwner;
    poll.expirationDate = [[NSDate date] dateByAddingTimeInterval:604800];
        
    poll.shouldDisplayAnswerTotals = NO;
    poll.shouldDisplayActivity = NO;
    
    [poll addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ created this poll.", poll.nameOfPollOwner]];
    
    return poll;
}

/* * * * * * * * * * * * * * * * *
    questionForPoll
 * * * * * * * * * * * * * * * * */
- (NSString *)questionForPoll {
    return self.pollFromParse[@"questionForPoll"];
}

- (void)setQuestionForPoll:(NSString *)questionForPoll {
    self.pollFromParse[@"questionForPoll"] = questionForPoll;
    [self save];
}

/* * * * * * * * * * * * * * * * *
    pollOwner
 * * * * * * * * * * * * * * * * */
- (void)setPollOwner:(PFUser *)pollOwner {
    self.pollFromParse[@"pollOwner"] = pollOwner;
    [self.pollFromParse saveInBackground];
}

- (PFUser *)pollOwner {
    return self.pollFromParse[@"pollOwner"];
}

/* * * * * * * * * * * * * * * * *
    nameOfPollOwner
 * * * * * * * * * * * * * * * * */
- (NSString *)nameOfPollOwner {
    return self.pollOwner[@"name"];
}

/* * * * * * * * * * * * * * * * *
    isCurrentUserPollOwner
 * * * * * * * * * * * * * * * * */
- (BOOL)isCurrentUserPollOwner {
    PFUser *pollOwner = self.pollOwner;
    PFUser *currentUser = [PFUser currentUser];
    
    if ([currentUser.objectId isEqualToString:pollOwner.objectId]) {
        return YES;
    } else {
        return NO;
    }
}

/* * * * * * * * * * * * * * * * *
    shouldDisplayActivity
 * * * * * * * * * * * * * * * * */
- (BOOL) shouldDisplayActivity {
    return [self.pollFromParse[@"shouldDisplayActivity"] boolValue];
}

- (void) setShouldDisplayActivity:(BOOL)shouldDisplayActivity {
    self.pollFromParse[@"shouldDisplayActivity"] = @(shouldDisplayActivity);
    [self save];
}

/* * * * * * * * * * * * * * * * *
    shouldDisplayAnswerTotals
 * * * * * * * * * * * * * * * * */
- (BOOL) shouldDisplayAnswerTotals {
    return [self.pollFromParse[@"shouldDisplayAnswerTotals"] boolValue];
}

- (void) setShouldDisplayAnswerTotals:(BOOL)shouldDisplayAnswerTotals {
    self.pollFromParse[@"shouldDisplayAnswerTotals"] = @(shouldDisplayAnswerTotals);
    [self save];
}

/* * * * * * * * * * * * * * * * *
 expirationDate
 * * * * * * * * * * * * * * * * */
- (NSDate *)expirationDate {
    return self.pollFromParse[@"expirationDate"];
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    self.pollFromParse[@"expirationDate"] = expirationDate;
    [self save];
}

/* * * * * * * * * * * * * * * * *
 friendsOfPoll
 * * * * * * * * * * * * * * * * */

- (NSArray *)friendsOfPoll {
    NSMutableArray *friendsOfPoll = [[NSMutableArray alloc] init];
    
    for (PFUser *user in self.pollFromParse[@"friendsOfPoll"]) {
        [friendsOfPoll addObject:[VFFriend friendFromPFUser:user]];
    }
    
    return [NSArray arrayWithArray:friendsOfPoll];
}

/* * * * * * * * * * * * * * * * *
 possibleAnswersForPoll
 * * * * * * * * * * * * * * * * */
- (NSArray *)possibleAnswersForPoll {
    NSMutableArray *possibleAnswersForPoll = [[NSMutableArray alloc] init];
    
    for (PFObject *answer in self.pollFromParse[@"possibleAnswersForPoll"]) {
        [possibleAnswersForPoll addObject:[VFAnswer createAnswerUsingPFObject:answer]];
    }
    
    return [NSArray arrayWithArray:possibleAnswersForPoll];
}

/* * * * * * * * * * * * * * * * *
 pollActivity
 * * * * * * * * * * * * * * * * */
- (NSArray *)pollActivity {
    NSMutableArray *pollActivity = [[NSMutableArray alloc] init];
    
    for (PFObject *activity in self.pollFromParse[@"pollActivity"]) {
        [pollActivity addObject:[VFActivity createActivityWithPFObjecct:activity]];
    }
    
    return [NSArray arrayWithArray:pollActivity];
}

/* * * * * * * * * * * * * * * * *
 indexOfSelectedAnswerFromCurrentUser
 * * * * * * * * * * * * * * * * */
- (NSInteger) indexOfSelectedAnswerFromCurrentUser {
    NSInteger returnValue = -1;
    
    NSInteger index = 0;
    for (VFAnswer *answer in self.possibleAnswersForPoll) {
        for (PFUser *user in answer.votedForByUsers) {
            if ([[PFUser currentUser].objectId isEqualToString:user.objectId]){
                returnValue = index;
            }
        }
        
        index++;
    }
    
    return returnValue;
}

/* * * * * * * * * * * * * * * * *
 Helper Methods
 * * * * * * * * * * * * * * * * */

- (void)addActivityToPollWithDescription:(NSString *)descriptionOfActivity {
    VFActivity *activity = [VFActivity createActivityWithDescription:descriptionOfActivity andDateAndTime:[NSDate date]];
    [self.pollFromParse addObjectsFromArray:@[activity.dataObjectFromParse] forKey:@"pollActivity"];
    [self save];
}

- (void)addFriendToPollByPFUser:(PFUser *)user {
    [VFPush sendPushNotificationToUsers:@[user] withNotificationString:[NSString stringWithFormat:@"You were sent a poll from %@. Please vote now!", self.nameOfPollOwner]];
    
    [self.pollFromParse addObjectsFromArray:@[user] forKey:@"friendsOfPoll"];
    [self save];
    
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ was invited", user[@"name"]]];
}

- (void)removeFriendOfPollAtIndex:(NSInteger)index {
    VFFriend *friend = self.friendsOfPoll[index];
    
    [self.pollFromParse removeObject:friend.pollFriend forKey:@"friendsOfPoll"];
    [self save];
    
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ was uninvited", friend.name]];
}

- (void)addPossibleAnswerForPollWithAnswerText:(NSString *)answerText {
    [VFPush sendPushNotificationToFriends:self.friendsOfPoll withNotificationString:[NSString stringWithFormat:@""]];
    VFAnswer *answer = [VFAnswer createAnswerUsingString:answerText];
    
    [self.pollFromParse addObjectsFromArray:@[answer.answerFromParse] forKey:@"possibleAnswersForPoll"];
    [self save];
    
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ added as answer", answerText]];
}

- (void)removePossibleAnswerFromPollAtIndex:(NSInteger)index {
    VFAnswer *answer = self.possibleAnswersForPoll[index];
    
    [self.pollFromParse removeObject:answer.answerFromParse forKey:@"possibleAnswersForPoll"];
    [answer deleteAnswer];
    
    [self save];
    
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ removed from answers", answer.answerText]];
}

- (void)refreshPoll {
    PFQuery *pollQuery = [PFQuery queryWithClassName:@"Polls"];
    [pollQuery whereKey:@"objectId" equalTo:self.pollFromParse.objectId];
    
    [pollQuery includeKey:@"pollOwner"];
    [pollQuery includeKey:@"friendsOfPoll"];
    [pollQuery includeKey:@"pollActivity"];
    [pollQuery includeKey:@"possibleAnswersForPoll"];
    [pollQuery includeKey:@"possibleAnswersForPoll.votedForByUsers"];
    
    [pollQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.pollFromParse = object;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pollObjectUpdated" object:nil];
    }];

}

- (void)deletePoll {
    for (VFAnswer *answerInPoll in self.possibleAnswersForPoll) {
        [answerInPoll deleteAnswer];
    }
    
    for (VFActivity *activity in self.pollActivity) {
        [activity deleteActivity];
    }
    
    [self.pollFromParse deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPollsList" object:nil];
        [VFPush sendPushNotificationToFriends:self.friendsOfPoll withNotificationString:[NSString stringWithFormat:@""]];
    }];
}

- (void)save {
    [self.pollFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    }];
}

@end
