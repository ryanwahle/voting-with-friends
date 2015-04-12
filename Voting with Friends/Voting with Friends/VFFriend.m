//
//  VFFriend.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

#import "VFFriend.h"

@interface VFFriend ()



@end

@implementation VFFriend

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)friendFromPFUser:(PFUser *)user {
    VFFriend *friend = [[VFFriend alloc] init];
    
    friend.pollFriend = user;
    
    return friend;
}

/* * * * * * * * * * * * * * * * *
    name
 * * * * * * * * * * * * * * * * */
- (NSString *)name {
    return self.pollFriend[@"name"];
}

/* * * * * * * * * * * * * * * * *
    email
 * * * * * * * * * * * * * * * * */
- (NSString *)email {
    return self.pollFriend[@"username"];
}

@end
