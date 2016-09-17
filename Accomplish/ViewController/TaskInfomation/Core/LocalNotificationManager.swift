//
//  LocalNotificationManager.swift
//  Accomplish
//
//  Created by zhoubo on 16/8/31.
//  Copyright © 2016年 zhoubo. All rights reserved.
//

import Foundation

struct LocalNotificationManager {
    let notifyKey = "com.zhou.achieve.task"
    let repeaterKey = "com.zhou.achieve.repeater"
    
    func notifyWithUUID(_ taskUUID: String) -> [UILocalNotification] {
        let notifications = UIApplication.shared.scheduledLocalNotifications
        guard let notifys = notifications else { return [] }
        return notifys.filter { (n) -> Bool in
            guard let userInfo = n.userInfo else { return false }
            guard let name = userInfo[notifyKey] as? String else { return false }
            return name == taskUUID
        }
    }
    
    func cancelNotify(_ taskUUID: String) {
        let notify = notifyWithUUID(taskUUID)
        guard notify.count > 0 else { return }
        for n in notify {
            UIApplication.shared.cancelLocalNotification(n)
        }
        debugPrint("clear local notifycation task uuid = \(taskUUID) success")
    }
    
    func updateNotify(_ task: Task, repeatInterval: NSCalendar.Unit) {
        guard let _ = task.notifyDate else  { return }
        
        let notify = self.notifyWithUUID(task.uuid)
        guard notify.count > 0 else {
            createNotify(task)
            return
        }
        
        for n in notify {
            UIApplication.shared.cancelLocalNotification(n)
        }
        createNotify(task)
    }
    
    func skipFireToday(skip: Bool, task: Task) {
        guard let repeater =
            RealmManager.shareManager.queryRepeaterWithTask(task.uuid) else {
                if skip {
                    self.cancelNotify(task.uuid)
                } else {
                    self.createNotify(task)
                }
                return
        }
        let notify = self.notifyWithUUID(task.uuid)
        
        if let type = RepeaterTimeType(rawValue: repeater.repeatType) {
            switch type {
            case .annual:
                let fireDate = notify.first?.fireDate as NSDate?
                notify.first?.fireDate =
                    (skip ? fireDate?.addingYears(1) : fireDate?.subtractingYears(1)) as Date?
            
            case .everyMonth:
                let fireDate = notify.first?.fireDate as NSDate?
                notify.first?.fireDate =
                    (skip ? fireDate?.addingMonths(1) : fireDate?.subtractingMonths(1)) as Date?
                
            case .everyWeek:
                let fireDate = notify.first?.fireDate as NSDate?
                notify.first?.fireDate =
                    (skip ? fireDate?.addingWeeks(1) : fireDate?.subtractingWeeks(1)) as Date?
             
            case .daily:
                let fireDate = notify.first?.fireDate as NSDate?
                notify.first?.fireDate =
                    (skip ? fireDate?.addingDays(1) : fireDate?.subtractingDays(1)) as Date?
                
            case .weekday:
                guard let notify = notify.filter({ (localNotify) -> Bool in
                    return (localNotify.fireDate as NSDate?)?.isToday() ?? false
                }).first else { break }
                
                let fireDate = notify.fireDate as NSDate?
                notify.fireDate =
                    (skip ? fireDate?.addingDays(7) : fireDate?.subtractingDays(7)) as Date?
            }
        }
        
    }
    
    func createNotify(_ task: Task) {
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
        
        notify.fireDate = notifyDate.clearSecond() as Date
        notify.soundName = UILocalNotificationDefaultSoundName
        notify.alertBody = task.getNormalDisplayTitle()
        notify.applicationIconBadgeNumber =
            UIApplication.shared.applicationIconBadgeNumber + 1
        notify.timeZone = TimeZone.current
        let info = [notifyKey: task.uuid]
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
                notify.repeatInterval = .weekOfYear
                notify.applicationIconBadgeNumber =
                    UIApplication.shared.applicationIconBadgeNumber + 1
                let info = [notifyKey: task.uuid]
                notify.userInfo = info
                
                UIApplication.shared.scheduleLocalNotification(notify)
            }
        }
    }
}

