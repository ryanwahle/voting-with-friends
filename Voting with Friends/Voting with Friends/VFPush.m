//
//  VFPush.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/14/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Parse;

#import "VFPush.h"
#import "VFFriend.h"

@implementation VFPush

// Register this device with the current user for push notifications
+ (void)registerPushNotifications {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
}

// Deregister this device and user for push notifications
+ (void)deregisterPushNotifications {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackground];
}

// Send a push notification to an array of VFFriend objects
+ (void)sendPushNotificationToFriends:(NSArray *)vfFriendsArray withNotificationString:(NSString *)notificationString {
    NSMutableArray *pfUsersArray = [[NSMutableArray alloc] init];
    
    for (VFFriend *friend in vfFriendsArray) {
        [pfUsersArray addObject:friend.pollFriend];
    }
    
    [VFPush sendPushNotificationToUsers:[NSArray arrayWithArray:pfUsersArray] withNotificationString:notificationString];
}

// Send a push notification to an array of PFUser objects.
+ (void)sendPushNotificationToUsers:(NSArray *)pfUserArray withNotificationString:(NSString *)notificationString {
    PFQuery *pushQuery = [PFInstallation query];
    
    [pushQuery whereKey:@"user" containedIn:pfUserArray];
    
    PFPush *pushNotification = [[PFPush alloc] init];
    [pushNotification setQuery:pushQuery];
    [pushNotification setMessage:notificationString];
    
    if (notificationString.length) {
        [pushNotification setData:@{@"sound":@"default",@"alert":notificationString}];
    }
    
    [pushNotification sendPushInBackground];
}

@end
