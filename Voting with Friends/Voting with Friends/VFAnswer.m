//
//  VFAnswer.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VFAnswer.h"

@implementation VFAnswer

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)createAnswerUsingString:(NSString *)string {
    VFAnswer *answer = [[VFAnswer alloc] init];
    
    answer.answerFromParse = [PFObject objectWithClassName:@"Answers"];
    [answer save];
    
    answer.answerText = string;
    
    return answer;
}

+ (instancetype)createAnswerUsingPFObject:(PFObject *)answerObject {
    VFAnswer *answer = [[VFAnswer alloc] init];
    
    answer.answerFromParse = answerObject;
    
    return answer;
}

/* * * * * * * * * * * * * * * * *
 answerText
 * * * * * * * * * * * * * * * * */
- (NSString *)answerText {
    return self.answerFromParse[@"answerText"];
}

- (void)setAnswerText:(NSString *)answerText {
    self.answerFromParse[@"answerText"] = answerText;
    [self save];
}

/* * * * * * * * * * * * * * * * *
 totalVotesForPoll
 * * * * * * * * * * * * * * * * */
- (NSInteger)totalVotesForPoll {
    return ((NSArray *)self.answerFromParse[@"votedForByUsers"]).count;
}

/* * * * * * * * * * * * * * * * *
 votedForByUsers
 * * * * * * * * * * * * * * * * */
- (NSArray *)votedForByUsers {
    NSMutableArray *votedForByUsers = [[NSMutableArray alloc] init];
    
    for (PFUser *user in self.answerFromParse[@"votedForByUsers"]) {
        [votedForByUsers addObject:user];
    }
    
    return [NSArray arrayWithArray:votedForByUsers];
}


/* * * * * * * * * * * * * * * * *
 Helper Methods
 * * * * * * * * * * * * * * * * */

- (void)save {
    [self.answerFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    }];
}

- (void)deleteAnswer {
    [self.answerFromParse deleteInBackground];
}

- (void)selectAnswerForCurrentUser {
    PFUser *user = [PFUser currentUser];
    [self.answerFromParse addObjectsFromArray:@[user] forKey:@"votedForByUsers"];
    [self save];
}

- (void)removeSelectedAnswerForCurrentUser {
    PFUser *user = [PFUser currentUser];
    [self.answerFromParse removeObjectsInArray:@[user] forKey:@"votedForByUsers"];
    [self save];
}

@end
