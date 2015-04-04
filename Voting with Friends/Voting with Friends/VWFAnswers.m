//
//  VWFAnswers.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/3/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VWFAnswers.h"
#import <Parse/PFObject+Subclass.h>

@implementation VWFAnswers

@dynamic pollAnswer;
@dynamic pollPointer;

@synthesize totalNumberOfVotes;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Answers";
}

- (void)updateTotalNumberOfVotes {
    PFQuery *totalVotesQuery = [VWFUserAnswerForPoll query];
    [totalVotesQuery whereKey:@"answerPointer" equalTo:[VWFAnswers objectWithoutDataWithObjectId:self.objectId]];
    NSLog(@"objectID: %@", self.objectId);
    
    [totalVotesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"updated votes");
            totalNumberOfVotes = objects.count;
        }
    }];
}

@end
