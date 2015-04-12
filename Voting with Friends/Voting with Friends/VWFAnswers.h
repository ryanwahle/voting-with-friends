//
//  VWFAnswers.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/3/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@class VWFPoll;

@interface VWFAnswers : PFObject <PFSubclassing>

@property VWFPoll *pollPointer;
@property NSString *pollAnswer;

@property NSInteger totalNumberOfVotes;

+ (NSString *)parseClassName;
- (void)updateTotalNumberOfVotes;

@end
