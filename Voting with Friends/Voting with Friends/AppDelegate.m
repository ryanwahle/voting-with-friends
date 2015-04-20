//
//  AppDelegate.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Parse;
#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Setup Parse
    [Parse setApplicationId:@"bzgd0ayJY8JwHeixEt4uZN78lefxVkIRXOfcnca1"
                  clientKey:@"1GJz5IHypQmpWy856B5RrJjjheLKXdbdPAvTSUgF"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
}

@end
