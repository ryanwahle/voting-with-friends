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
        
    poll.shouldDisplayAnswerTotals = NO;
    poll.shouldDisplayActivity = NO;
    
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

- (void)addFriendToPollByPFUser:(PFUser *)user {
    [self.pollFromParse addObjectsFromArray:@[user] forKey:@"friendsOfPoll"];
    [self save];
}

- (void)removeFriendOfPollAtIndex:(NSInteger)index {
    [self.pollFromParse removeObject:((VFFriend *)self.friendsOfPoll[index]).pollFriend forKey:@"friendsOfPoll"];
    [self save];
}

- (void)addPossibleAnswerForPollWithAnswerText:(NSString *)answerText {
    VFAnswer *answer = [VFAnswer createAnswerUsingString:answerText];
    
    [self.pollFromParse addObjectsFromArray:@[answer.answerFromParse] forKey:@"possibleAnswersForPoll"];
    [self save];
}

- (void)removePossibleAnswerFromPollAtIndex:(NSInteger)index {
    VFAnswer *answer = self.possibleAnswersForPoll[index];
    
    [self.pollFromParse removeObject:answer.answerFromParse forKey:@"possibleAnswersForPoll"];
    [answer deleteAnswer];
    
    [self save];
}

- (void)deletePoll {
    for (VFAnswer *answerInPoll in self.possibleAnswersForPoll) {
        [answerInPoll deleteAnswer];
    }
    
    [self.pollFromParse deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPollsList" object:nil];
    }];
}

- (void)save {
    [self.pollFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    }];
}

@end
