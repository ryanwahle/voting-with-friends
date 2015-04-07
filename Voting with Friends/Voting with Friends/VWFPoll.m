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
@synthesize pollFriends;
@synthesize currentSelectedAnswer;

@dynamic showActivity;
@dynamic showIndividualAnswerTotals;
@dynamic createdByUserPointer;
@synthesize nameOfCreatedByUser;

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
            // Get the poll creators name
            PFQuery *userQuery = [PFUser query];
            [userQuery getObjectInBackgroundWithId:self.createdByUserPointer.objectId block:^(PFObject *object, NSError *error) {
                self.nameOfCreatedByUser = object[@"name"];
            }];
            
            // Get a list of friends
            PFQuery *pollFriendsQuery = [VWFUserAnswerForPoll query];
            [pollFriendsQuery whereKey:@"pollPointer" equalTo:[VWFPoll objectWithoutDataWithObjectId:self.objectId]];
            
            [pollFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Poll Friends Error: %@", error);
                } else {
                    self.pollFriends = objects;
                }
            }];

            
            // Get a list of possible answers for poll
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
                
                // Get the users currently selected answer
                PFQuery *currentAnswerQuery = [VWFUserAnswerForPoll query];
                [currentAnswerQuery whereKey:@"pollPointer" equalTo:[VWFPoll objectWithoutDataWithObjectId:self.objectId]];
                [currentAnswerQuery whereKey:@"userPointer" equalTo:[PFUser objectWithoutDataWithObjectId:[PFUser currentUser].objectId]];
                
                [currentAnswerQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (error) {
                        NSLog(@"Error: %@", error);
                        self.currentSelectedAnswer = nil;
                    } else {
                        self.currentSelectedAnswer = (VWFUserAnswerForPoll *)object;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:notificationString object:nil];
                }];
            }];
        }
    }];
}

- (void)addFriend:(NSString *)objectIdForPFUser {
        VWFUserAnswerForPoll *newUser = [VWFUserAnswerForPoll object];
        newUser.pollPointer = [VWFPoll objectWithoutDataWithObjectId:self.objectId];
        newUser.userPointer = [PFUser objectWithoutDataWithObjectId:objectIdForPFUser];
        
        [newUser saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // Refresh the data from the database and update tableview
                [self refreshCloudDataAndPostNotification:@"addEditPoll_cloudDataUpdated"];
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
