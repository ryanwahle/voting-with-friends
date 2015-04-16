//
//  VFActivity.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/15/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@interface VFActivity : NSObject

@property PFObject *dataObjectFromParse;

@property NSDate *dateAndTimeOfActivity;
@property NSString *descriptionOfActivity;


+ (instancetype)createActivityWithDescription:(NSString *)descriptionOfActivity andDateAndTime:(NSDate *)dateAndTimeOfActivity;
+ (instancetype)createActivityWithPFObjecct:(PFObject *)pfObject;

- (void)save;
- (void)deleteActivity;

@end
