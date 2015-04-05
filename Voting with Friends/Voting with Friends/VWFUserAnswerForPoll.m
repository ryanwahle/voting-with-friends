//
//  VWFUserAnswerForPoll.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/3/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VWFUserAnswerForPoll.h"
#import <Parse/PFObject+Subclass.h>

@implementation VWFUserAnswerForPoll

@dynamic pollPointer;
@dynamic answerPointer;
@dynamic userPointer;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserAnswerForPoll";
}

@end
