//
//  VWFUserAnswerForPoll.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/3/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "VWFPoll.h"
@class VWFPoll;
@class VWFAnswers;

@interface VWFUserAnswerForPoll : PFObject <PFSubclassing>

@property VWFPoll *pollPointer;
@property VWFAnswers *answerPointer;
@property PFUser *userPointer;

+ (NSString *)parseClassName;

@end
