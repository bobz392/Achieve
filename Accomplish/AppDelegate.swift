//
//  AppDelegate.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CoreSpotlight

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let root = HomeViewController()
        let nav = UINavigationController(rootViewController: root)
        nav.isNavigationBarHidden = true
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        RealmManager.configMainRealm()

        // background fetch
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if #available(iOS 9.0, *) {
            self.configureDynamicShortcuts()
            let re = self.watchManger.session?.isReachable
            Logger.log("watchManger.session?.isReachable = \(re)")
        }
        
        HUD.sharedHUD.config()
        
        Fabric.with([Crashlytics.self])
        Crashlytics.sharedInstance().debugMode = true
        
        return true
    }
    
    // MRAK: - todo handle notify
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Logger.log("didReceiveLocalNotification = \(notification)")
        application.applicationIconBadgeNumber -= 1
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        application.applicationIconBadgeNumber -= 1
        
        guard let uuid = notification.userInfo?[kNotifyUserInfoKey] as? String else {
            return
        }
        
        if identifier == kNotifyFinishAction {
            guard let task = RealmManager.shareManager.queryTask(uuid) else {
                return
            }
            
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
        } else if identifier == kNotifyReschedulingAction {
            UrlSchemeDispatcher().checkTaskDetail(uuid)
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
//        let repeaterManager = RepeaterManager()
//        if repeaterManager.isNewDay() {
//            completionHandler(.newData)
//
//            guard let nav = application.keyWindow?.rootViewController as? UINavigationController else {
//                return
//            }
//            guard let vc = nav.viewControllers.first as? HomeViewController else {
//                return
//            }
//            vc.handleNewDay()
//        } else {
//            completionHandler(.noData)
//        }
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return UrlSchemeDispatcher().handleUrl(url)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

@available(iOS 9.0, *)
extension AppDelegate {
    @objc(application:performActionForShortcutItem:completionHandler:) func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickActionDispatcher().dispatch(shortcutItem, completion: completionHandler)
    }
    
    func configureDynamicShortcuts() {
        let createTaskItem = UIApplicationShortcutItem(
            type: QuickActionType.Create.rawValue,
            localizedTitle: Localized("shortCutCreate"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(type: .add),
            userInfo: nil)
        
        let calendarIcon = UIApplicationShortcutIcon(templateImageName: "Calendar")
        let calendarItem = UIApplicationShortcutItem(
            type: QuickActionType.Calendar.rawValue,
            localizedTitle: Localized("shortCutCalendar"),
            localizedSubtitle: "",
            icon: calendarIcon,
            userInfo: nil)
        
        let searchTaskItem = UIApplicationShortcutItem(
            type: QuickActionType.Search.rawValue,
            localizedTitle: Localized("searchHolder"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(type: .search),
            userInfo: nil)
        
        UIApplication.shared.shortcutItems =
            [ createTaskItem, calendarItem, searchTaskItem ]
    }

}

// MARK: - watch kit
@available(iOS 9.0, *)
extension AppDelegate {
    var watchManger: WatchManager {
        get {
            return WatchManager.shareManager
        }
    }
}

// MARK: - handoff delegate
extension AppDelegate {
    
    @objc(application:continueUserActivity:restorationHandler:) func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType,
                let uuid = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                UrlSchemeDispatcher().checkTaskDetail(uuid)
            }
        }
        
        return true
    }
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        return false
    }
}
