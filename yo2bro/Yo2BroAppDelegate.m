//
//  AppDelegate.m
//  yo2bro
//
//  Created by Mason, Darren J on 4/30/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Yo2BroAppDelegate.h"

@interface Yo2BroAppDelegate ()

@end

@implementation Yo2BroAppDelegate


+ (void)initialize
{
    
    [FBSDKLoginButton class];
    [FBSDKProfilePictureView class];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [application setStatusBarHidden:YES];
    
    // Enable storing and querying data from Local Datastore. Remove this line if you don't want to
    // use Local Datastore features or want to use cachePolicy.
    [Parse enableLocalDatastore];
    
    //parse key
    [Parse setApplicationId:@"EBWv1ekvvWg9SNZqeNurbfoAg2doI3LKCjo3wsOS"
                  clientKey:@"XYfH8OYdjkvef6gJmMCaUtOZxROr9pCtBb9WVymQ"];
    
    [PFUser enableRevocableSessionInBackground];
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced in iOS 7).
        // In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark Push Notifications

//this happens after login
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
        } else {
            NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
        }
    }];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
                 
                 PFUser *user = [PFUser user];
                 user.username = result[@"email"];
                 user.password = @"password";
                 user.email = result[@"email"];
                 
                 [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (!error) {
                         // Hooray! Let them use the app now.
                         [self addDevice:deviceToken andEmail:user.email];
                         
                     } else {
                         NSString *errorString = [error userInfo][@"error"];
                         NSLog(@"ERROR:%@",errorString);
                     }
                 }];
                 
             }
         }];
    }
}

-(void)addDevice:(NSData *)deviceToken andEmail:(NSString*)email{
    //login now
    
    [PFUser logInWithUsernameInBackground:email password:@"password"
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            //Install user to parse
                                            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                            [currentInstallation setDeviceTokenFromData:deviceToken];
                                            currentInstallation[@"userId"] = [user objectId];
                                            [currentInstallation saveInBackground];
                                        } else {
                                            // The login failed. Check error to see why.
                                        }
                                    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


@end
