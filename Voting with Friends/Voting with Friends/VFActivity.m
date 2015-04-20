//
//  VFActivity.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/15/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VFActivity.h"

@implementation VFActivity

+ (instancetype)createActivityWithPFObjecct:(PFObject *)pfObject {
    VFActivity *activity = [[VFActivity alloc] init];
    
    activity.dataObjectFromParse = pfObject;
    
    return activity;
}

+ (instancetype)createActivityWithDescription:(NSString *)descriptionOfActivity andDateAndTime:(NSDate *)dateAndTimeOfActivity {
    VFActivity *activity = [[VFActivity alloc] init];
    activity.dataObjectFromParse = [PFObject objectWithClassName:@"Activity"];
    
    activity.descriptionOfActivity = descriptionOfActivity;
    activity.dateAndTimeOfActivity = dateAndTimeOfActivity;
    
    return activity;
}

/* * * * * * * * * * * * * * * * *
 descriptionOfActivity
 * * * * * * * * * * * * * * * * */
- (NSString *)descriptionOfActivity {
    return self.dataObjectFromParse[@"descriptionOfActivity"];
}

- (void)setDescriptionOfActivity:(NSString *)descriptionOfActivity {
    self.dataObjectFromParse[@"descriptionOfActivity"] = descriptionOfActivity;
}

/* * * * * * * * * * * * * * * * *
 dataAndTimeOfActivity
 * * * * * * * * * * * * * * * * */
- (NSDate *)dateAndTimeOfActivity {
    return self.dataObjectFromParse[@"dateAndTimeOfActivity"];
}

- (void)setDateAndTimeOfActivity:(NSDate *)dateAndTimeOfActivity {
    self.dataObjectFromParse[@"dateAndTimeOfActivity"] = dateAndTimeOfActivity;
}


/* * * * * * * * * * * * * * * * *
 Helper Methods
 * * * * * * * * * * * * * * * * */

- (void)save {
    //[self.dataObjectFromParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    //}];
    
    [self.dataObjectFromParse saveInBackground];
}

- (void)deleteActivity {
    [self.dataObjectFromParse deleteInBackground];
}

@end
