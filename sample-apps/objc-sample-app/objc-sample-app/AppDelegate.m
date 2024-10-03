//
//  AppDelegate.m
//  objc-sample-app
//
//  Created by Tapash Majumder on 6/21/18.
//  Copyright © 2018 Iterable. All rights reserved.
//


#import "AppDelegate.h"
#import "DeepLinkHandler.h"

@import IterableSDK;

@interface AppDelegate ()
@end

@implementation AppDelegate

// ITBL: Set your actual API key here
NSString *iterableApiKey = @"";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //ITBL: Setup Notifications
    [self setupNotifications];
    
    //ITBL: Initialize API
    IterableConfig *config = [[IterableConfig alloc] init];
    config.urlDelegate = self;
    config.customActionDelegate = self;
    
    [IterableAPI initializeWithApiKey: iterableApiKey
                        launchOptions: launchOptions
                               config: config];
    
    //ITBL: Set your user's email here
    IterableAPI.email = @"user@domain.com";
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //ITBL:
    // You don't need to do this in your app. Just set the correct value for 'iterableApiKey' when it is declared.
    if ([iterableApiKey isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"API Key Required" message:@"You must set Iterable API Key. Run this app again after setting 'AppDelegate.iterableApiKey'." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        [alert addAction:action];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //ITBL:
    if (IterableAPI.email == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please Login" message:@"You must set 'IterableAPI.email' before receiving push notifications from Iterable." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavController"];
            [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
        }];
        [alert addAction:action];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Silent Push
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [IterableAppIntegration application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

#pragma mark - Url handling
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    //ITBL:
    NSURL *url = userActivity.webpageURL;
    if (url == nil) {
        return NO;
    }
    
    return [IterableAPI handleUniversalLink:url];
}

#pragma mark - notification registration
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [IterableAPI registerToken:deviceToken];
}

#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [IterableAppIntegration userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
}

#pragma mark - IterableURLDelegate
// return true if we handled the url
- (BOOL)handleIterableURL:(NSURL *)url context:(IterableActionContext *)context {
    return [DeepLinkHandler handleURL:url];
}

#pragma mark - IterableCustomActionDelegate
// handle the cutom action from push
// return value true/false doesn't matter here, stored for future use
- (BOOL)handleIterableCustomAction:(IterableAction *)action context:(IterableActionContext *)context {
    if ([action.type isEqualToString:@"handleFindCoffee"]) {
        if (action.userInput != nil) {
            NSString *urlString = [[NSString alloc] initWithFormat:@"https://example.com/coffee?q=%@", action.userInput];
            NSURL *url = [[NSURL alloc] initWithString:urlString];
            return [DeepLinkHandler handleURL:url];
        }
    }

    return FALSE;
}

#pragma mark - private
//ITBL:
// Ask for permission for notifications etc.
// setup self as delegate to listen to push notifications.
- (void) setupNotifications {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
            // not authorized, ask for permission
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIApplication.sharedApplication registerForRemoteNotifications];
                    });
                } // TODO: handle errors
            }];
        } else {
            // already authorized
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication.sharedApplication registerForRemoteNotifications];
            });
        }
    }];
}

@end
