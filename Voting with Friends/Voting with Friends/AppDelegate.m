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
    
    // Setup remote notifications
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

// This is called when getting a remote notification. If it has a message attached to it, then it was sent to display information to the user so
// an alert box is displayed. Otherwise if it does not have a message attached, then it is just to tell us that data needs to be reloaded from
// the parse database.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    
    NSString *alertString = userInfo[@"aps"][@"alert"];
    
    if (alertString.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Voting with Friends" message:alertString preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction:alertOK];
        
        [self.window.rootViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
    }
}

// This is for local notifcations like reminders to the user about placing their vote, and alerting users that the poll has expired.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:notification.alertTitle message:notification.alertBody preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:alertOK];
    
    [self.window.rootViewController.presentedViewController presentViewController:alert animated:YES completion:nil];
}

// Refresh the cloud data whenever we open the app. We don't want stale data.
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cloudDataRefreshed" object:nil];
}

@end
