//
//  VFFriend.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/7/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@interface VFFriend : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString *email;

@property PFUser *pollFriend;

+ (instancetype)friendFromPFUser:(PFUser *)user;

@end
