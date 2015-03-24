//
//  VWFPoll.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/24/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface VWFPoll : PFObject <PFSubclassing>

//@property NSDate *createdAt;
@property NSString *pollQuestion;

@property BOOL showActivity;
@property BOOL showIndividualAnswerTotals;


+ (NSString *)parseClassName;

@end
