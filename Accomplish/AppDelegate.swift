//
//  AppDelegate.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/23.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import WatchConnectivity

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
        
        self.configRealm()
        self.register(application)
        
        if #available(iOS 9.0, *) {
            self.configureDynamicShortcuts()
            let re = self.watchManger.session?.isReachable
            debugPrint(re)
        }
        
        HUD.sharedHUD.config()
        
        Fabric.with([Crashlytics.self])
        Crashlytics.sharedInstance().debugMode = true
        
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        debugPrint("didReceiveLocalNotification = \(notification)")
        application.applicationIconBadgeNumber -= 1
    }
    
    fileprivate func register(_ application: UIApplication) {
        let settings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        //        let action = UIMutableUserNotificationAction()
        //        action.identifier = "action"
        //        action.title = "添加task"
        //        action.activationMode = .Foreground
        //        if #available(iOS 9.0, *) {
        //            action.behavior = .TextInput
        //        }
        //        action.authenticationRequired = false
        //        action.destructive = false
        //
        //        let catrgory = UIMutableUserNotificationCategory()
        //        catrgory.identifier = "catrgory"
        //        catrgory.setActions([action], forContext: .Default)
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    fileprivate func configRealm() {
        let config = Realm.Configuration()
        Realm.Configuration.defaultConfiguration = config
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let repeaterManager = RepeaterManager()
        if repeaterManager.isNewDay() {
            completionHandler(.newData)
            
            guard let nav = application.keyWindow?.rootViewController as? UINavigationController else {
                return
            }
            guard let vc = nav.viewControllers.first as? HomeViewController else {
                return
            }
            vc.handleNewDay()
        } else {
            completionHandler(.noData)
        }
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
        
        application.applicationIconBadgeNumber = 0
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
        let shortcutItem1 = UIApplicationShortcutItem(
            type: QuickActionType.Create.rawValue,
            localizedTitle: Localized("shortCutCreate"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(type: .add),
            userInfo: nil)
        
        let icon = UIApplicationShortcutIcon(templateImageName: "Calendar")
        let shortcutItem2 = UIApplicationShortcutItem(
            type: QuickActionType.Calendar.rawValue,
            localizedTitle: Localized("shortCutCalendar"),
            localizedSubtitle: "",
            icon: icon,
            userInfo: nil)
        
        UIApplication.shared.shortcutItems =
            [ shortcutItem1, shortcutItem2 ]
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
//
//    fileprivate func configWatchManager() {
//        let manager = WatchManager()
//    }
    
//    func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
//        debugPrint(userInfo)
//        reply([AnyHashable(1) : "asd"])
//    }
}

