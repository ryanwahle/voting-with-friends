//
//  AppDelegate.m
//  Voting with Friends
//
//  Created by Ryan Wahle on 3/18/15.
//  Copyright (c) 2015 Ryan Wahle. All rights reserved.
//

@import Parse;

#import "AppDelegate.h"
#import "VFPoll.h"
#import "VFFriend.h"
#import "VFAnswer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Setup Parse
    [Parse setApplicationId:@"bzgd0ayJY8JwHeixEt4uZN78lefxVkIRXOfcnca1"
                  clientKey:@"1GJz5IHypQmpWy856B5RrJjjheLKXdbdPAvTSUgF"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    /*
     TEST OUT THE NEW OBJECTS HERE
     */
    
    [PFUser logInWithUsername:@"test2@test.com" password:@"test"];
    
    NSString *pollQuestion = @"What would you like to eat tomorrow?";
    
    VFPoll *poll = [VFPoll createPollWithQuestion: pollQuestion
                                        pollOwner: [PFUser currentUser]];
    
    [poll addFriendToPollByPFUser:[PFUser currentUser]];
    
    [PFUser logInWithUsername:@"ryanwahle@fullsail.edu" password:@"test"];
    [poll addFriendToPollByPFUser:[PFUser currentUser]];
    
    [PFUser logInWithUsername:@"ryanwahle@yahoo.com" password:@"test"];
    [poll addFriendToPollByPFUser:[PFUser currentUser]];
    
    NSLog(@"Poll Owner: %@", poll.nameOfPollOwner);
    NSLog(@"isCurrentUserPollOwner: %d", poll.isCurrentUserPollOwner);
    
    poll.shouldDisplayAnswerTotals = NO;
    poll.shouldDisplayActivity = YES;
    NSLog(@"DisplayAnswerTotals: %d, DisplayActivity: %d", poll.shouldDisplayAnswerTotals, poll.shouldDisplayActivity);

    for (VFFriend *friend in poll.friendsOfPoll) {
        NSLog(@"Friend From Poll: %@ (%@)", friend.name, friend.email);
    }

    
    [poll removeFriendOfPollAtIndex:1];
    
    
    for (VFFriend *friend in poll.friendsOfPoll) {
        NSLog(@"Friend From Poll: %@ (%@)", friend.name, friend.email);
    }

    [poll addPossibleAnswerForPollWithAnswer:[VFAnswer createAnswerUsingString:@"McDonalds"]];
    [poll addPossibleAnswerForPollWithAnswer:[VFAnswer createAnswerUsingString:@"Jack in the Box"]];
    [poll addPossibleAnswerForPollWithAnswer:[VFAnswer createAnswerUsingString:@"The Habit"]];
    [poll addPossibleAnswerForPollWithAnswer:[VFAnswer createAnswerUsingString:@"Paradise Bakery"]];
    
    for (VFAnswer *answer in poll.possibleAnswersForPoll) {
        [answer selectAnswerForCurrentUser];
        NSLog(@"Possible Answer for Poll: %@ - Votes: %ld", answer.answerText, (long)answer.totalVotesForPoll);
    }
    
    for (VFAnswer *answer in poll.possibleAnswersForPoll) {
        NSLog(@"Possible Answer for Poll: %@ - Votes: %ld", answer.answerText, (long)answer.totalVotesForPoll);
    }

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
