//
//  VFPush.h
//  Voting with Friends
//
//  Created by Ryan Wahle on 4/14/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Foundation;
@import Parse;

@interface VFPush : NSObject

+ (void)registerPushNotifications;
+ (void)deregisterPushNotifications;

+ (void)sendPushNotificationToUsers:(NSArray *)pfUserArray withNotificationString:(NSString *)notificationString;
+ (void)sendPushNotificationToFriends:(NSArray *)vfFriendsArray withNotificationString:(NSString *)notificationString;

@end
