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

@implementation VFPoll

+ (instancetype)createPollWithPFObject:(PFObject *)object {
    VFPoll *poll = [[VFPoll alloc] init];
    
    poll.pollFromParse = object;
    
    return poll;
}

+ (instancetype)createPollForUser:(PFUser *)pollOwner {
    VFPoll *poll = [[VFPoll alloc] init];
    
    poll.pollFromParse = [PFObject objectWithClassName:@"Polls"];
    poll.pollOwner = pollOwner;
    
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
}

/* * * * * * * * * * * * * * * * *
    pollOwner
 * * * * * * * * * * * * * * * * */
- (void)setPollOwner:(PFUser *)pollOwner {
    self.pollFromParse[@"pollOwner"] = pollOwner;
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
    isPollExpired
 * * * * * * * * * * * * * * * * */
- (BOOL)isPollExpired {
    if (self.expirationDate && [self.expirationDate earlierDate:[NSDate date]] == self.expirationDate) {
        return YES;
    }
    
    return NO;
}


/* * * * * * * * * * * * * * * * *
    shouldDisplayActivity
 * * * * * * * * * * * * * * * * */
- (BOOL) shouldDisplayActivity {
    return [self.pollFromParse[@"shouldDisplayActivity"] boolValue];
}

- (void) setShouldDisplayActivity:(BOOL)shouldDisplayActivity {
    self.pollFromParse[@"shouldDisplayActivity"] = @(shouldDisplayActivity);
}

/* * * * * * * * * * * * * * * * *
    shouldDisplayAnswerTotals
 * * * * * * * * * * * * * * * * */
- (BOOL) shouldDisplayAnswerTotals {
    return [self.pollFromParse[@"shouldDisplayAnswerTotals"] boolValue];
}

- (void) setShouldDisplayAnswerTotals:(BOOL)shouldDisplayAnswerTotals {
    self.pollFromParse[@"shouldDisplayAnswerTotals"] = @(shouldDisplayAnswerTotals);
}

/* * * * * * * * * * * * * * * * *
 expirationDate
 * * * * * * * * * * * * * * * * */
- (NSDate *)expirationDate {
    if (self.pollFromParse[@"expirationDate"] == [NSNull null]) {
        return nil;
    } else {
        return self.pollFromParse[@"expirationDate"];
    }
}

- (void)setExpirationDate:(NSDate *)expirationDate {
    if (expirationDate) {
        self.pollFromParse[@"expirationDate"] = expirationDate;
    } else {
        self.pollFromParse[@"expirationDate"] = [NSNull null];
    }
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
    
    NSLog(@"Possible Answers Count: %lu", (unsigned long)possibleAnswersForPoll.count);
    
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
    
    [pollActivity sortUsingComparator:^NSComparisonResult(VFActivity *obj1, VFActivity *obj2) {
        return [obj2.dateAndTimeOfActivity compare:obj1.dateAndTimeOfActivity];
    }];
    
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
    [activity save];
    
    [self.pollFromParse addObjectsFromArray:@[activity.dataObjectFromParse] forKey:@"pollActivity"];
}

- (void)addFriendObjectToPoll:(VFFriend *)friend {
    [VFPush sendPushNotificationToUsers:@[friend.pollFriend] withNotificationString:[NSString stringWithFormat:@"You were sent a poll from %@. Please vote now!", self.nameOfPollOwner]];
    
    [self.pollFromParse addObject:friend.pollFriend forKey:@"friendsOfPoll"];
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ was invited", friend.name]];
}

- (void)removeFriendObjectFromPoll:(VFFriend *)friend {
    [self.pollFromParse removeObject:friend.pollFriend forKey:@"friendsOfPoll"];
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ was uninvited", friend.name]];
}

- (void)addAnswerObjectToPoll:(VFAnswer *)answer {
    [self.pollFromParse addObject:answer.answerFromParse forKey:@"possibleAnswersForPoll"];
    [self addActivityToPollWithDescription:[NSString stringWithFormat:@"%@ added as answer", answer.answerText]];
}

- (void)removeAnswerObjectFromPoll:(VFAnswer *)answer {
    [self.pollFromParse removeObject:answer.answerFromParse forKey:@"possibleAnswersForPoll"];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
        [VFPush sendPushNotificationToFriends:self.friendsOfPoll withNotificationString:[NSString stringWithFormat:@""]];
    }];
}

- (void)save {
    [self.pollFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    }];
}

@end
