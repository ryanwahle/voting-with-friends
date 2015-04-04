//
//  VWFPoll.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VWFPoll.h"
#import <Parse/PFObject+Subclass.h>

@implementation VWFPoll

@dynamic pollQuestion;
@synthesize pollAnswerKeys;
@synthesize currentSelectedAnswer;

@dynamic showActivity;
@dynamic showIndividualAnswerTotals;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Polls";
}

- (void)refreshCloudDataAndPostNotification:(NSString *)notificationString {
    [self fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            PFQuery *answersQuery = [VWFAnswers query];
            [answersQuery whereKey:@"pollPointer" equalTo:[VWFPoll objectWithoutDataWithObjectId:self.objectId]];
            [answersQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                } else {
                    self.pollAnswerKeys = objects;
                    
                    for (VWFAnswers *answer in objects) {
                        [answer updateTotalNumberOfVotes];
                    }
                }
                
                PFQuery *currentAnswerQuery = [VWFUserAnswerForPoll query];
                [currentAnswerQuery whereKey:@"pollPointer" equalTo:[VWFPoll objectWithoutDataWithObjectId:self.objectId]];
                [currentAnswerQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (error) {
                        NSLog(@"Error: %@", error);
                        self.currentSelectedAnswer = nil;
                    } else {
                        NSLog(@"current selected answer object: %@", object);
                        self.currentSelectedAnswer = (VWFUserAnswerForPoll *)object;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:notificationString object:nil];
                }];
            }];
        }
    }];
}

- (void)deletePoll {
    // Delete UserAnswerForPoll by pollPointer
    PFQuery *allUserAnswersForPollQuery = [VWFUserAnswerForPoll query];
    
    [allUserAnswersForPollQuery whereKey:@"pollPointer" equalTo:[VWFPoll objectWithoutDataWithObjectId:self.objectId]];
    
    [allUserAnswersForPollQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [VWFUserAnswerForPoll deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            NSLog(@"Deleted all UserAnswerForPoll poll data");
        }];
    }];
    
    // Delete Answers by pollPointer
    [VWFAnswers deleteAllInBackground:self.pollAnswerKeys block:^(BOOL succeeded, NSError *error) {
        NSLog(@"Deleted all Answers poll data");
    }];
    
    // Delete Poll by objectId
    [self deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Deleted poll data");
    }];
}

@end
