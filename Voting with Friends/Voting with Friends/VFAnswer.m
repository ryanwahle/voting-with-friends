//
//  VFAnswer.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VFAnswer.h"

@implementation VFAnswer

+ (instancetype)createAnswerUsingString:(NSString *)string {
    VFAnswer *answer = [[VFAnswer alloc] init];
    
    answer.answerFromParse = [PFObject objectWithClassName:@"Answers"];
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
    
    NSLog(@"\n\n\nVOTED BY FOR USERS\n%@", self.answerFromParse[@"votedForByUsers"]);
    
    for (PFUser *user in self.answerFromParse[@"votedForByUsers"]) {
        [votedForByUsers addObject:user];
    }
    
    return [NSArray arrayWithArray:votedForByUsers];
}

- (BOOL)isSelectedForCurrentUser {
    for (PFUser *user in self.answerFromParse[@"votedForByUsers"]) {
        if ([[PFUser currentUser].objectId isEqualToString:user.objectId]) {
            return true;
        }
    }
    
    return false;
}

/* * * * * * * * * * * * * * * * *
 Helper Methods
 * * * * * * * * * * * * * * * * */

- (void)save {
    [self.answerFromParse saveInBackground];
}

- (void)deleteAnswer {
    [self.answerFromParse deleteInBackground];
}

- (void)selectAnswerForCurrentUser {
    PFUser *user = [PFUser currentUser];
    [self.answerFromParse addObjectsFromArray:@[user] forKey:@"votedForByUsers"];
}

- (void)removeSelectedAnswerForCurrentUser {
    PFUser *user = [PFUser currentUser];
    [self.answerFromParse removeObjectsInArray:@[user] forKey:@"votedForByUsers"];
}

@end
