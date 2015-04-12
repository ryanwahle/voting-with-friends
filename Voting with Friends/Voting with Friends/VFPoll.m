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

@property PFObject *pollFromParse;

@end


@implementation VFPoll

- (instancetype)init {
    self = [super init];
    
    if (self) {
    
    }
    
    return self;
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

- (void)addPossibleAnswerForPollWithAnswer:(VFAnswer *)answer {
    [self.pollFromParse addObjectsFromArray:@[answer.answerFromParse] forKey:@"possibleAnswersForPoll"];
    [self save];
}

- (void)removePossibleAnswerFromPollAtIndex:(NSInteger)index {
    [self.pollFromParse removeObject:((VFAnswer *)self.possibleAnswersForPoll[index]).answerFromParse forKey:@"possibleAnswersForPoll"];
    [self save];
}

- (void)save {
    [self.pollFromParse saveInBackground];
}

@end
