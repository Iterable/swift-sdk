//
//  AppDelegate.swift
//  swift-sample-app
//
//  Created by Tapash Majumder on 6/13/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

import UIKit
import UserNotifications

import IterableSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    // ITBL: Set your actual api key here.
    let iterableApiKey = ""
    
    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // ITBL: Setup Notification
        setupNotifications()
        
        // ITBL: Initialize API
        let config = IterableConfig()
        config.customActionDelegate = self
        config.urlDelegate = self
        config.inAppDisplayInterval = 1
        
        IterableAPI.initialize(apiKey: iterableApiKey,
                               launchOptions: launchOptions,
                               config: config)
        
        return true
    }
    
    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // ITBL:
        // You don't need to do this in your app. Just set the correct value for 'iterableApiKey' when it is declared.
        if iterableApiKey == "" {
            let alert = UIAlertController(title: "API Key Required", message: "You must set Iterable API Key. Run this app again after setting 'AppDelegate.iterableApiKey'.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                exit(0)
            }
            alert.addAction(action)
            window?.rootViewController?.present(alert, animated: true)
            return
        }
        
        // ITBL:
        if !LoginViewController.checkIterableEmailOrUserId().eitherPresent {
            let alert = UIAlertController(title: "Please Login", message: "You must set 'IterableAPI.email or IterableAPI.userId' before receiving push notifications from Iterable.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavController")
                self.window?.rootViewController?.present(vc, animated: true)
            }
            alert.addAction(action)
            window?.rootViewController?.present(alert, animated: true)
            return
        }
    }
    
    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: Silent Push for in-app
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        IterableAppIntegration.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    // MARK: Deep link
    
    func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        
        // ITBL:
        return IterableAPI.handle(universalLink: url)
    }
    
    // MARK: Notification
    
    // ITBL:
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IterableAPI.register(token: deviceToken)
    }
    
    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}
    
    // ITBL:
    // Ask for permission for notifications etc.
    // setup self as delegate to listen to push notifications.
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                // not authorized, ask for permission
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                    if success {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    // TODO: Handle error etc.
                }
            } else {
                // already authorized
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

// MARK: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from applicationDidFinishLaunching:.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // ITBL:
        IterableAppIntegration.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}

// MARK: IterableURLDelegate

extension AppDelegate: IterableURLDelegate {
    // return true if we handled the url
    func handle(iterableURL url: URL, inContext _: IterableActionContext) -> Bool {
        DeepLinkHandler.handle(url: url)
    }
}

// MARK: IterableCustomActionDelegate

extension AppDelegate: IterableCustomActionDelegate {
    // handle the cutom action from push
    // return value true/false doesn't matter here, stored for future use
    func handle(iterableCustomAction action: IterableAction, inContext _: IterableActionContext) -> Bool {
        if action.type == "handleFindCoffee" {
            if let query = action.userInput {
                return DeepLinkHandler.handle(url: URL(string: "https://example.com/coffee?q=\(query)")!)
            }
        }
        return false
    }
}
