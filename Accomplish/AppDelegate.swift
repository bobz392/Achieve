//
//  AppDelegate.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let root = HomeViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        configRealm()
        register(application)
        HUD.sharedHUD.config()
        
        
        if application.backgroundRefreshStatus == .Available {
            debugPrint("Available")
        } else if application.backgroundRefreshStatus == .Denied {
            debugPrint("Denied")
        } else {
            debugPrint("Restricted")
        }
        
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        debugPrint("didReceiveLocalNotification = \(notification)")
        application.applicationIconBadgeNumber -= 1
    }
    
    private func register(application: UIApplication) {
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    private func configRealm() {
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        //        debugPrint(RealmManager.shareManager.queryTodayTaskList(finished: false))
        debugPrint("background fetch")
        
        let repeaterManager = RepeaterManager()
        if repeaterManager.isNewDay() {
            completionHandler(.NewData)
            
            guard let nav = application.keyWindow?.rootViewController as? UINavigationController else {
                debugPrint("UINavigationController is not ")
                return
            }
            guard let vc = nav.viewControllers.first as? HomeViewController else {
                debugPrint("HomeViewController is not ")
                return
            }
            debugPrint("handle new day")
            vc.handleNewDay()
        } else {
            completionHandler(.NoData)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

