//
//  LocalNotificationManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation
import UserNotifications

let kNotifyFinishAction = "notify.finish"
let kNotifyReschedulingAction = "notify.rescheduling"
let kNotificationCategory = "notify.category"
let kNotifyUserInfoKey = "com.zhou.achieve.task"


class LocalNotificationManager: NSObject {
    
    let repeaterKey = "com.zhou.achieve.repeater"
    private let enableUN = false
    
    static let shared = LocalNotificationManager()
    
    override fileprivate init() {
        super.init()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    func create(_ task: Task) {
        if #available(iOS 10.0, *) , enableUN {
            self.createUNNotify(task)
        } else {
            self.createNotify(task)
        }
    }
    
    func cancel(_ task: Task) {
        if #available(iOS 10.0, *) , enableUN {
            self.cancelUNNotify(task)
        } else {
            self.cancelNotify(task)
        }
        
        Logger.log("clear local notifycation task uuid = \(task.uuid) success")
    }
    
    func update(_ task: Task) {
        if #available(iOS 10.0, *) , enableUN{
            self.updateUNNotify(task)
        } else {
            self.updateNotify(task)
        }
    }
    
    func removeRepeater(_ task: Task) {
        if #available(iOS 10.0, *) , enableUN {
            //            self.deleteUNTaskRepeater(task)
        } else {
            self.deleteTaskRepeater(task)
        }
    }
    
    func skipFireToday(skip: Bool, task: Task) {
        if #available(iOS 10.0, *) , enableUN {
            self.skipUNToday(skip: skip, task: task)
        } else {
            self.skipToday(skip: skip, task: task)
        }
    }
    
    // MARK: -  private
    fileprivate func notifyWithUUID(_ taskUUID: String) -> [UILocalNotification] {
        let notifications = UIApplication.shared.scheduledLocalNotifications
        guard let notifys = notifications else { return [] }
        
        var uuidSet: Set<String>
        if let repeater = RealmManager.shareManager.queryRepeaterWithTask(taskUUID) {
            if repeater.repeatType == RepeaterTimeType.weekday.rawValue {
                let uuidArray = (2..<7).map({ (weekday) -> String in
                    return repeater.repeatQueryTaskUUID + "\(weekday)"
                })
                uuidSet = Set<String>(uuidArray)
            } else {
                uuidSet = Set<String>()
                uuidSet.insert(repeater.repeatQueryTaskUUID)
            }
        } else {
            uuidSet = Set<String>()
            uuidSet.insert(taskUUID)
        }
        
        return notifys.filter({ (n) -> Bool in
            guard let userInfo = n.userInfo else { return false }
            guard let name = userInfo[kNotifyUserInfoKey]
                as? String else { return false }
            return uuidSet.contains(name)
        })
    }
    
    fileprivate func cancelNotify(_ task: Task) {
        let notify = self.notifyWithUUID(task.uuid)
        guard notify.count > 0 else { return }
        for n in notify {
            UIApplication.shared.cancelLocalNotification(n)
        }
    }
    
    /**
     仅仅删除 repeater 的时候调用
     返回是否删除成功
     **/
    fileprivate func deleteTaskRepeater(_ task: Task) {
        // 删除 repeater 本身
        RealmManager.shareManager.deleteRepeater(task)
        
        let notify = self.notifyWithUUID(task.uuid)
        guard notify.count > 0 else { return }
        
        // 备份一份 fire date，以便创建一个今日通知
        guard let firedate = notify.first?.fireDate as NSDate? else { return }
        
        // 不论如何，删掉 repeater 的时候，需要删除所有通知
        for n in notify {
            UIApplication.shared.cancelLocalNotification(n)
        }
        
        // 如果 fire date 还没到，创建一个今日通知
        // 同时因为已经删除 repeater 所以只需要 create 即可
        if firedate.isEarlierThan(Date()) {
            self.createNotify(task)
        }
    }
    
    fileprivate func updateNotify(_ task: Task) {
        guard let _ = task.notifyDate else  { return }
        
        let notify = self.notifyWithUUID(task.uuid)
        guard notify.count > 0 else {
            self.createNotify(task)
            return
        }
        
        for n in notify {
            UIApplication.shared.cancelLocalNotification(n)
        }
        self.createNotify(task)
    }
    
    fileprivate func skipToday(skip: Bool, task: Task) {
        guard let repeater =
            RealmManager.shareManager.queryRepeaterWithTask(task.uuid) else {
                if skip {
                    self.cancelNotify(task)
                } else {
                    self.createNotify(task)
                }
                return
        }
        
        let notifys = self.notifyWithUUID(task.uuid)
        
        var notify: UILocalNotification?
        var datecomponents: DateComponents?
        let calendar = Calendar.current
        let now = NSDate()
        
        if let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            switch type {
            case .annual:
                notify = notifys.first
                guard let firedate = notify?.fireDate else { break }
                datecomponents =
                    calendar.dateComponents([.hour, .minute], from: firedate)
                datecomponents?.day = now.day()
                datecomponents?.month = now.month()
                datecomponents?.year = skip ? now.year() + 1 : now.year()
                
                
            case .everyMonth:
                notify = notifys.first
                guard let firedate = notify?.fireDate else { break }
                datecomponents =
                    calendar.dateComponents([.hour, .minute], from: firedate)
                datecomponents?.day = now.day()
                datecomponents?.month = skip ? now.month() + 1 : now.month()
                datecomponents?.year = now.year()
                
                
            case .everyWeek:
                notify = notifys.first
                guard let firedate = notify?.fireDate else { break }
                datecomponents =
                    calendar.dateComponents([.hour, .minute], from: firedate)
                datecomponents?.weekday = now.weekday()
                datecomponents?.year = now.year()
                datecomponents?.month = now.month()
                datecomponents?.weekOfYear = skip ? now.weekOfYear() + 1 : now.weekOfYear()
                
            case .daily:
                notify = notifys.first
                guard let firedate = notify?.fireDate else { break }
                datecomponents =
                    calendar.dateComponents([.hour, .minute], from: firedate)
                datecomponents?.day = skip ? now.day() + 1 : now.day()
                datecomponents?.month = now.month()
                datecomponents?.year = now.year()
                
            case .weekday:
                guard let notif = notifys.filter({ (n) -> Bool in
                    guard let firedate = n.fireDate as NSDate? else { return false }
                    return firedate.weekday() == NSDate().weekday()
                }).first else { return }
                
                notify = notif
                guard let firedate = notify?.fireDate else { break }
                datecomponents =
                    calendar.dateComponents([.hour, .minute], from: firedate)
                datecomponents?.day = skip ? now.day() + 7 : now.day()
                datecomponents?.month = now.month()
                datecomponents?.year = now.year()
            }
            
            guard let n = notify,
                let dc = datecomponents,
                let notifyUUID = n.userInfo?[kNotifyUserInfoKey] as? String else {
                    return
            }
            
            let nextfireDate = calendar.date(from: dc)
            
            UIApplication.shared.cancelLocalNotification(n)
            
            let newLocalNotify = UILocalNotification()
            newLocalNotify.repeatInterval = type.getCalendarUnit()
            newLocalNotify.fireDate = nextfireDate
            newLocalNotify.alertTitle = Localized("taskReminding")
            newLocalNotify.alertBody = task.getNormalDisplayTitle()
            newLocalNotify.soundName = UILocalNotificationDefaultSoundName
            newLocalNotify.category = kNotificationCategory
            newLocalNotify.applicationIconBadgeNumber =
                UIApplication.shared.applicationIconBadgeNumber + 1
            newLocalNotify.timeZone = TimeZone.current
            let info = [kNotifyUserInfoKey: notifyUUID]
            newLocalNotify.userInfo = info
            
            UIApplication.shared.scheduleLocalNotification(newLocalNotify)
            Logger.log("new fire date = \(newLocalNotify.fireDate)")
        }
        
    }
    
    fileprivate func createNotify(_ task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        
        let notify = UILocalNotification()
        
        let repeater = RealmManager.shareManager.queryRepeaterWithTask(task.uuid)
        if let repeater = repeater,
            let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            if type == .weekday {
                self.createWeekday(task: task)
                return
            } else {
                notify.repeatInterval = type.getCalendarUnit()
            }
        } else {
            notify.repeatInterval = NSCalendar.Unit(rawValue: 0)
        }
        
        notify.alertTitle = Localized("taskReminding")
        notify.alertBody = task.getNormalDisplayTitle()
        notify.fireDate = notifyDate.clearSecond() as Date
        notify.soundName = UILocalNotificationDefaultSoundName
        notify.category = kNotificationCategory
        notify.applicationIconBadgeNumber =
            UIApplication.shared.applicationIconBadgeNumber + 1
        notify.timeZone = TimeZone.current
        let info = [kNotifyUserInfoKey: task.uuid]
        notify.userInfo = info
        
        UIApplication.shared.scheduleLocalNotification(notify)
    }
    
    fileprivate func createWeekday(task: Task) {
        guard let notifyDate = task.notifyDate?.clearSecond() else { return }
        
        for i in 0 ..< 7 {
            let fireDate = notifyDate.addingDays(i) as NSDate
            if fireDate.isWeekend() {
                continue
            }else {
                let notify = UILocalNotification()
                notify.fireDate = fireDate as Date
                notify.soundName = UILocalNotificationDefaultSoundName
                notify.alertBody = task.getNormalDisplayTitle()
                notify.timeZone = TimeZone.current
                notify.category = kNotificationCategory
                notify.repeatInterval = .weekOfYear
                notify.applicationIconBadgeNumber =
                    UIApplication.shared.applicationIconBadgeNumber + 1
                let info = [kNotifyUserInfoKey: task.uuid + "\(fireDate.weekday())"]
                notify.userInfo = info
                
                UIApplication.shared.scheduleLocalNotification(notify)
            }
        }
    }
    
    // MARK: - authorization and reigster
    func requestAuthorization() {
        let ud = AppUserDefault()
        if !ud.readBool(kUserFirstTimeCallNoitification) {
            self.register()
            ud.write(kUserFirstTimeCallNoitification, value: true)
        }
    }
    
    fileprivate func register() {
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    let actionFinish = UNNotificationAction(
                        identifier: kNotifyFinishAction,
                        title: Localized("finishTask"),
                        options: UNNotificationActionOptions.foreground
                    )
                    
                    let actionRescheduling = UNNotificationAction(
                        identifier: kNotifyReschedulingAction,
                        title: Localized("rescheduling"),
                        options: .foreground)
                    
                    let category = UNNotificationCategory(identifier: kNotificationCategory, actions: [actionFinish, actionRescheduling], intentIdentifiers: [], options: .customDismissAction)
                    
                    UNUserNotificationCenter.current().setNotificationCategories([category])
                }
            }
        } else {
            let action = UIMutableUserNotificationAction()
            action.identifier = kNotifyFinishAction
            action.title = Localized("finishTask")
            action.activationMode = .foreground
            if #available(iOS 9.0, *) {
                action.behavior = .default
            }
            action.isAuthenticationRequired = false
            action.isDestructive = false
            
            let action2 = UIMutableUserNotificationAction()
            action2.identifier = kNotifyReschedulingAction
            action2.title = Localized("rescheduling")
            action2.activationMode = .foreground
            if #available(iOS 9.0, *) {
                action.behavior = .default
            }
            action2.isAuthenticationRequired = false
            action2.isDestructive = false
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = kNotificationCategory
            category.setActions([action, action2], for: .default)
            
            let settings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: [category])
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
    }
}

@available (iOS 10.0, *)
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("userNotificationCenter willPresent =\(notification)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber -= 1
        
        guard let uuid = response.notification.request.content.userInfo[kNotifyUserInfoKey] as? String else {
            return
        }
        switch response.actionIdentifier {
        case kNotifyFinishAction:
            guard let task = RealmManager.shareManager.queryTask(uuid) else {
                return
            }
            
            RealmManager.shareManager.updateTaskStatus(task, status: kTaskFinish)
            
        case kNotifyReschedulingAction:
            UrlSchemeDispatcher().checkTaskDetail(uuid)
            
        default:
            break
        }
        
        completionHandler()
    }
    
    func logAllUNNotify() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (request) in
            Logger.log(request)
        }
        
    }
    
    fileprivate func cancelUNNotify(_ task: Task) {
        var weekdayUUIDs = (2..<7).map { (index) -> String in
            return task.uuid + "\(index)"
        }
        weekdayUUIDs.append(task.uuid)
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: weekdayUUIDs)
    }
    
    fileprivate func updateUNNotify(_ task: Task) {
        guard let _ = task.notifyDate else  { return }
        
        self.cancelUNNotify(task)
        self.createUNNotify(task)
    }
    
    //    fileprivate func skipTodayNewFireDate() ->
    
    fileprivate func skipUNToday(skip: Bool, task: Task) {
        guard let repeater =
            RealmManager.shareManager.queryRepeaterWithTask(task.uuid) else {
                if skip {
                    self.cancelUNNotify(task)
                } else {
                    self.createUNNotify(task)
                }
                return
        }
        
        let repeatType = repeater.repeatType
        guard let type = RepeaterTimeType(rawValue: repeatType) else { return }
        
        let uuid =
            type == .weekday ?
                repeater.repeatQueryTaskUUID + "\(NSDate().weekday())" :
                repeater.repeatQueryTaskUUID
        
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            Logger.log("requests.count = \(requests.count)")
            for request in requests {
                if request.identifier == uuid {
                    let content = request.content
                    
                    guard
                        let trigger = request.trigger as? UNCalendarNotificationTrigger,
                        let firedate = trigger.nextTriggerDate()
                        else { break }
                    
                    let nsfiredate = firedate as NSDate
                    
//                    guard let movefiredate = nsfiredate
//                        .secAndHourMoveNow(min: nsfiredate.minute(), hour: nsfiredate.hour())
//                        else { return }
                    
                    var newfiredate: Date

                    switch type {
                    case .annual:
                        newfiredate =
                            skip ? nsfiredate.addingYears(1) : (nsfiredate as Date)
//                        datecomponents.day = now.day()
//                        datecomponents.month = now.month()
//                        datecomponents.year = skip ? now.year() + 1 : now.year()
                        
                    case .everyMonth:
                        newfiredate =
                            skip ? nsfiredate.addingMonths(1) : (nsfiredate as Date)
//                        datecomponents.day = now.day()
//                        datecomponents.month = skip ? now.month() + 1 : now.month()
//                        datecomponents.year = now.year()
                        
                        
                    case .everyWeek:
                        newfiredate =
                            skip ? nsfiredate.addingWeeks(1) : (nsfiredate as Date)
//                        datecomponents.weekday = now.weekday()
//                        datecomponents.year = now.year()
//                        datecomponents.month = now.month()
//                        datecomponents.weekOfYear
//                            = skip ? now.weekOfYear() + 1 : now.weekOfYear()
                        
                    case .daily:
                        newfiredate =
                            skip ? nsfiredate.addingDays(1) : (nsfiredate as Date)
//                        datecomponents.day = skip ? now.day() + 1 : now.day()
//                        datecomponents.month = now.month()
//                        datecomponents.year = now.year()
                        
                    case .weekday:
                        newfiredate =
                            skip ? nsfiredate.addingDays(7) : (nsfiredate as Date)
//                        datecomponents.day = skip ? now.day() + 7 : now.day()
//                        datecomponents.month = now.month()
//                        datecomponents.year = now.year()
                    }
                    
                    let calendar = Calendar.current
                    let datecomponents =
                        calendar.dateComponents(type.getCalendarComponent(), from: newfiredate)
                    
                    let newTrigger =
                        UNCalendarNotificationTrigger(dateMatching: datecomponents, repeats: true)
                    
                    debugPrint("newTrigger.nextTriggerDate = \(newTrigger.nextTriggerDate())")
                
//                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuid])
                    
                    let newRequest = UNNotificationRequest(identifier: uuid, content: content, trigger: newTrigger)
                    UNUserNotificationCenter.current().add(newRequest)
                }
            }
        }
    }
    
    fileprivate func createUNNotify(_ task: Task) {
        guard let notifyDate = task.notifyDate else { return }
        
        let trigger: UNCalendarNotificationTrigger
        var dateComponents: DateComponents
        
        let repeater = RealmManager.shareManager.queryRepeaterWithTask(task.uuid)
        if let repeater = repeater,
            let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            
            if type == .weekday {
                self.createUNWeekday(task: task, type: type)
                return
            } else {
                let component = type.getCalendarComponent()
                dateComponents = Calendar.current
                    .dateComponents(component, from: notifyDate as Date)
                
            }
            
            trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: true)
        } else {
            dateComponents = Calendar.current
                .dateComponents([.nanosecond, .second, .minute], from: notifyDate as Date)
            trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        }
        
        let content = self.createUNNotificationContent(task: task)
        let request = UNNotificationRequest(identifier: task.uuid, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                Logger.log("Notification scheduled success \(request.identifier)")
            }
        }
    }
    
    fileprivate func createUNNotificationContent(task: Task) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Localized("taskReminding")
        content.body = task.getNormalDisplayTitle()
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = kNotificationCategory
        let info = [kNotifyUserInfoKey: task.uuid]
        content.userInfo = info
        
        return content
    }
    
    fileprivate func createUNWeekday(task: Task, type: RepeaterTimeType) {
        guard let notifyDate = task.notifyDate?.clearSecond() else { return }
        
        for i in 0 ..< 7 {
            let fireDate = notifyDate.addingDays(i) as NSDate
            if fireDate.isWeekend() {
                continue
            }else {
                let content = self.createUNNotificationContent(task: task)
                let component = type.getCalendarComponent()
                let dateComponents = Calendar.current
                    .dateComponents(component, from: fireDate as Date)
                
                let trigger =
                    UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                
                let request =
                    UNNotificationRequest(identifier: task.uuid + "\(fireDate.weekday())", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if error == nil {
                        Logger.log("Notification scheduled success \(request.identifier)")
                    }
                }
            }
        }
    }
    
    func testClearUNNoitifcation() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
