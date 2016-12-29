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
    weak var drawer: MMDrawerController? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = self.createDrawer()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        
        // background fetch
        if application.backgroundRefreshStatus != .available {
            // to do
        } else {
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        }
        
        if #available(iOS 9.0, *) {
            self.configureDynamicShortcuts()
            let re = self.watchManger.session?.isReachable
            Logger.log("watchManger.session?.isReachable = \(re)")
        }
        
        HUD.shared.config()
        
        Fabric.with([Crashlytics.self])
        #if debug
            Crashlytics.sharedInstance().debugMode = true
        #else
            Crashlytics.sharedInstance().debugMode = false
        #endif
        
        RealmManager.configMainRealm()
        
        return true
    }
    
    fileprivate func createDrawer() -> UINavigationController{
        let homeVC = HomeViewController()
        let menuVC = MenuViewController()
        menuVC.cacheHomeVC = homeVC
        drawer = MMDrawerController(center: homeVC,
                                    leftDrawerViewController: menuVC)
        let nav = UINavigationController(rootViewController: drawer!)
        drawer?.view.backgroundColor = Colors.mainBackgroundColor
        nav.isNavigationBarHidden = true
        drawer?.maximumLeftDrawerWidth = UIScreen.main.bounds.width * 0.8
        self.setOpenDrawMode(openMode: true)
        drawer?.showsShadow = true
        drawer?.shadowOpacity = 0.2
        drawer?.closeDrawerGestureModeMask = .all
        drawer?.setDrawerVisualStateBlock(MMDrawerVisualState.parallaxVisualStateBlock(withParallaxFactor: 3.0))
        
        return nav
    }
    
    func setOpenDrawMode(openMode: Bool) {
        if openMode {
            self.drawer?.openDrawerGestureModeMask = [.panningCenterView, .bezelPanningCenterView]
        } else {
            self.drawer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode(rawValue: 0)
        }
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
            guard let task = RealmManager.shared.queryTask(uuid) else {
                return
            }
            
            RealmManager.shared.updateTaskStatus(task, newStatus: .completed)
        } else if identifier == kNotifyReschedulingAction {
            UrlSchemeDispatcher().checkTaskDetail(uuid)
        }
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if RepeaterManager().isNewDay() {
            completionHandler(.noData)
            return
        }
        
        self.checkHasShareExtensionData()
        completionHandler(.noData)
    }
    
    /**
     处理 share extension 中创建的任务
     */
    private func checkHasShareExtensionData() {
        guard let userDefault = GroupUserDefault() else { return }
        let shares = userDefault.getReadLatersOrTask()
        
        if shares.count > 0 {
            Logger.log("shares data = \(shares)")
            userDefault.clearShareData()
            
            
            var tasks = [Task]()
            var readLaters = [ReadLater]()
            for share in shares {
                if share.type == .PlainText {
                    let task = Task()
                    task.createdDate = share.date
                    task.createDefaultTask(share.linkOrContent)
                    tasks.append(task)
                } else {
                    let readLater = ReadLater()
                    readLater.name = share.name
                    readLater.uuid = share.uuid
                    readLater.link = share.linkOrContent
                    readLater.createdAt = share.date
                    readLaters.append(readLater)
                }
            }
            
            RealmManager.shared.writeObjects(tasks)
            RealmManager.shared.writeObjects(readLaters)
        } else {
            Logger.log("no share extension data created")
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.checkHasShareExtensionData()
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
            return WatchManager.shared
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
