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
@dynamic showActivity;
@dynamic showIndividualAnswerTotals;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Polls";
}

@end
