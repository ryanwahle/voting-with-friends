//
//  VFAnswer.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@interface VFAnswer : NSObject

@property PFObject *answerFromParse;

@property NSString *answerText;
@property (readonly) NSInteger totalVotesForPoll;

+ (instancetype)createAnswerUsingString:(NSString *)string;
+ (instancetype)createAnswerUsingPFObject:(PFObject *)answer;

- (void)selectAnswerForCurrentUser;
    
@end
